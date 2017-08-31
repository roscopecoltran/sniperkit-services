package main

import (
    "os"
    "os/exec"
    "github.com/fsouza/go-dockerclient"
    // "github.com/fgrehm/go-dockerpty"
    "github.com/matthieudelaro/go-dockerpty"
    log "github.com/Sirupsen/logrus"
    "strings"
    "fmt"
    "github.com/matthieudelaro/nut/nvidia"
    "os/user"
    Config "github.com/matthieudelaro/nut/config"
    Utils "github.com/matthieudelaro/nut/utils"
    // "errors"
)

// Start the container, execute the list of commands, and then stops the container.
// Inspired from https://github.com/fsouza/go-dockerclient/issues/287
// and from https://github.com/fsouza/go-dockerclient/issues/220#issuecomment-77777365
// DONE: solve key issue (Ctrl+C, q, ...). See if that can help: https://github.com/fgrehm/go-dockerpty : it does :)
// DONE: to solve tty size, use func (c *Client) ResizeContainerTTY(id string, height, width int) error : solved with dockerpty
// and/or func (c *Client) ResizeExecTTY(id string, height, width int) error
// TODO: report bug "StartExec Error: %s read /dev/stdin: bad file descriptor" when executing several commands : post issue on dockerpty
// func execMacro(macro Config.Macro) {
func execInContainer(commands []string, config Config.Config, context Utils.Context, useDockerCLI bool) {
    log.Debug("commands (len = ", len(commands), ") : ", commands)
    var cmdConfig []string
    if len(commands) == 0 {
        log.Debug("Given list of commands is empty.")
        cmdConfig = []string{}
    } else if len(commands) == 1 {
        cmdConfig = []string{"sh", "-c", commands[0]}
    } else {
        cmdConfig = []string{"sh", "-c", strings.Join(commands, "; ")}
    }
    log.Debug("cmdConfig: ", cmdConfig)

    imageName := Config.GetDockerImage(config)
    if imageName == "" {
        log.Error("Docker image has not been defined.")
        return
    }

    var client *docker.Client
    var err error
    if !useDockerCLI {
        client, err = getDockerClient()
        if err != nil {
            log.Error("Could not reach Docker host: ", err.Error())
            return
        }
        log.Debug("Created client")
    } else {
        log.Debug("Using Docker CLI")
    }


    // prepare names of directories/volumes to mount
    // inspired from https://github.com/fsouza/go-dockerclient/issues/220#issuecomment-77777365
    volumes := Config.GetVolumes(config, context)
    binds := make([]string, 0, len(volumes))
    portBindings := map[docker.Port][]docker.PortBinding{}
    exposedPorts := map[docker.Port]struct{}{}
    envVariables := []string{}
    volumeDriver := ""
    devices := []docker.Device{}
    hostUidGid := ""

    for key, volume := range(volumes) {
        volumeName := Config.GetVolumeName(volume)
        hostPath, hostPathErr := Config.GetFullHostPath(volume, context)
        containerPath, containerPathErr := Config.GetFullContainerPath(volume, context)
        log.Debug(key, " / ", len(volumes), " volume", volume)
        if containerPathErr != nil {
            log.Error("Couldn't mount container directory (" + containerPath + "): ", containerPathErr.Error())
            return
        }
        if hostPathErr != nil { // volume must have either a hostPath to a directory, ...
            log.Debug(key, " unproper hostPath", hostPath)
            if volumeName != "" { // ..., or a volumeName
                log.Debug(key, " volume name", volumeName)
                if useDockerCLI {
                    binds = append(binds, volumeName + ":" + containerPath)
                } else {
                    // prepare volume
                    var dockerVolume *docker.Volume
                    if dockerVolume, err = client.InspectVolume(volumeName); err != nil {
                        fmt.Println("Could not inspect volume", imageName, ":", err.Error())
                        fmt.Println("Creating volume...")

                        if dockerVolume, err = client.CreateVolume(
                            docker.CreateVolumeOptions{Name: volumeName}); err != nil {
                            log.Error("Could not create volume: ", err.Error())
                            return
                        }
                        fmt.Println("Volume created.")
                    }
                    log.Debug(key, " dockerVolume ", dockerVolume)
                    log.Debug(key, " dockerVolume ", dockerVolume.Name)
                    log.Debug(key, " dockerVolume ", dockerVolume.Mountpoint)
                    log.Debug(key, " dockerVolume ", dockerVolume.Driver)
                    binds = append(binds, dockerVolume.Mountpoint + ":" + containerPath)
                    // TODO?: take dockerVolume.Driver into account?
                }
            } else {
                log.Error("Couldn't mount host directory (" + hostPath + "): ", hostPathErr.Error())
                return
            }
        } else {
            log.Debug(key, " proper host path", hostPath, hostPathErr)
            binds = append(binds, hostPath + ":" + containerPath)
        }
    }
    log.Debug("binds", binds)

    for _, value := range Config.GetPorts(config) {
        parts := strings.Split(value, ":") // TODO: support ranges of ports
        hostPort := ""
        containerPort := ""
        if len(parts) == 2 {
            hostPort = parts[0]
            containerPort = parts[1]
        } else if len(parts) == 1 {
            hostPort = parts[0]
            containerPort = parts[0]
        } else {
            log.Error("Could not parse port: " + value)
            return
        }
        // name := containerPort + "/tcp" // TODO: support UDP
        // dockerPort := docker.Port{containerPort + "/tcp"}
        var dockerPort docker.Port = docker.Port(containerPort + "/tcp")
        exposedPorts[dockerPort] = struct{}{}
        portBindings[dockerPort] = []docker.PortBinding{
            // {HostIP: "0.0.0.0", HostPort: "8080",}}
            {HostPort: hostPort,}} // TODO: support HostIP
    }

    // Add environment variables.
    // Timezone feature: in order to synchronize the timezone
    //     of the container with the one of the host, set the variable TZ.
    //     (See http://www.cyberciti.biz/faq/linux-unix-set-tz-environment-variable/)
    //     So, if TZ variable is not set in the configuration, then set
    //     it to the host timezone information.
    foundTZvariable := false
    for name, value := range Config.GetEnvironmentVariables(config) {
        envVariables = append(envVariables, name + "=" + value)
        if name == "TZ" {
            foundTZvariable = true
        }
    }
    if !foundTZvariable {
        envVariables = append(envVariables, "TZ" + "=" + Utils.GetTimezoneOffsetToTZEnvironmentVariableFormat())
    }

    if Config.IsGUIEnabled(config) {
        portBindingsGUI, envVariablesGUI, bindsGUI, err := enableGui()
        if err != nil {
            log.Error("Could not enable GUI: ", err.Error())
        } else {
            envVariables = append(envVariables, envVariablesGUI...)
            binds = append(binds, bindsGUI...)
            for k, v := range portBindingsGUI {
                portBindings[k] = v
            }
        }
    }
    for _, device := range Config.GetDevices(config) {
        devices = append(devices, docker.Device{
            PathOnHost: Config.GetHostPath(device),
            PathInContainer: Config.GetContainerPath(device),
            CgroupPermissions: Config.GetOptions(device),
        })
    }
    if Config.IsNvidiaDevicesEnabled(config) {
        nvidiaDevices, driverName, driverVolume, err := nvidia.GetConfiguration()
        if err != nil {
            log.Error("Could not enable Nvidia devices: ", err,
                "\nYou have to be on Linux for this to work. Also, make sure " +
                "that nvidia-docker-plugin is running.\n")
        } else {
            binds = append(binds, driverVolume)
            volumeDriver = driverName
            for _, devicePath := range nvidiaDevices {
                devices = append(devices, docker.Device{
                    PathOnHost: devicePath,
                    PathInContainer: devicePath,
                    CgroupPermissions: "mrw",
                })
            }
        }
    }

    if Config.IsCurrentUserEnabled(config) {
        if hostUser, err := user.Current(); err != nil {
            if err.Error() == "user: Current not implemented on darwin/amd64" {
                // This error is expected on osx. It is not a problem since
                // files created by container (both Docker for Mac and
                // Docker Toolbox) have the UID and GID of the current user
                // by default
            } else {
                log.Error("Couldn't inspect host current user: ", err.Error())
                return
            }
        } else {
            hostUidGid = hostUser.Uid + ":" + hostUser.Gid
        }
    }

    //Try to create a container from the imageID
    dockerConfig := docker.Config{
        Image:        imageName,
        Cmd:          cmdConfig,
        OpenStdin:    true,
        StdinOnce:    true,
        AttachStdin:  true,
        AttachStdout: true,
        AttachStderr: true,
        Tty:          true,
        WorkingDir:   Config.GetWorkingDir(config),
        Env:          envVariables,
        ExposedPorts: exposedPorts,
        VolumeDriver: volumeDriver,
        User:         hostUidGid,
    }

    dockerHostConfig := docker.HostConfig{
        Binds: binds,
        PortBindings: portBindings,
        Privileged: Config.IsPrivileged(config),
        SecurityOpt: Config.GetSecurityOpts(config),
        Devices: devices,
        UTSMode: Config.GetUTSMode(config),
        NetworkMode: Config.GetNetworkMode(config),
    }

    if useDockerCLI {
        dockercall := []string{"run", "-it", "--rm"}
        if dockerConfig.WorkingDir != "" {
            dockercall = append(dockercall, "--workdir=" + dockerConfig.WorkingDir)
        }
        for _, volumeName := range dockerHostConfig.Binds {
            dockercall = append(dockercall, "--volume=" + volumeName)
        }
        if dockerConfig.VolumeDriver != "" {
            dockercall = append(dockercall, "--volume-driver=" + dockerConfig.VolumeDriver)
        }
        if dockerConfig.User != "" {
            dockercall = append(dockercall, "--user=" + dockerConfig.User)
        }
        for _, envVariable := range dockerConfig.Env {
            dockercall = append(dockercall, "--env=\"" + envVariable + "\"")
        }
        for _, port := range Config.GetPorts(config) { // TODO: use dockerConfig.ExposedPorts instead (after fixing it)
            dockercall = append(dockercall, "--publish=\"" + port + "\"")
        }
        if dockerHostConfig.Privileged {
            dockercall = append(dockercall, "--privileged")
        }
        if value := dockerHostConfig.NetworkMode; value != "" {
            dockercall = append(dockercall, "--uts=\"" + value + "\"")
        }
        if value := dockerHostConfig.UTSMode; value != "" {
            dockercall = append(dockercall, "--net=\"" + value + "\"")
        }
        for _, value := range dockerHostConfig.SecurityOpt {
            dockercall = append(dockercall, "--security-opt=\"" + value + "\"")
        }
        for _, device := range dockerHostConfig.Devices {
            value := device.PathOnHost + ":" + device.PathInContainer
            if device.CgroupPermissions != "" {
                value += ":" + device.CgroupPermissions
            }
            dockercall = append(dockercall, "--device=\"" + value + "\"")
        }
        dockercall = append(dockercall, imageName)
        dockercall = append(dockercall, dockerConfig.Cmd...)
        log.Debug(append([]string{"docker"}, dockercall...))
        c := exec.Command("docker", dockercall...)

        c.Stdout = os.Stdout
        c.Stdin = os.Stdin
        c.Stderr = os.Stderr
        if err = c.Run(); err != nil {
            log.Error("Error while calling Docker CLI: ", err.Error())
        }
    } else {
        //Pull image from Registry, if not present
        _, err = client.InspectImage(imageName)
        if err != nil {
            fmt.Println("Could not inspect image", imageName, ":", err.Error())

            fmt.Println("Pulling image...")
            opts := docker.PullImageOptions{Repository: imageName}
            err = client.PullImage(opts, docker.AuthConfiguration{})
            if err != nil {
                log.Error("Could not pull image ", imageName, ": ", err.Error())
                return
            }
            fmt.Println("Pulled image")
        }

        // TODO: ? Give the container a name? Can be done with docker.CreateContainerOptions{Name: "nut_myproject"}
        // opts2 := docker.CreateContainerOptions{Name: "nut_" + , Config: &dockerConfig}
        opts2 := docker.CreateContainerOptions{
            Config: &dockerConfig,
            HostConfig: &dockerHostConfig,
        }
        container, err := client.CreateContainer(opts2)
        if err != nil {
            log.Error("Couldn't create container: ", err.Error())
            return
        } else {
            defer func() {
                err = client.RemoveContainer(docker.RemoveContainerOptions{
                    ID: container.ID,
                    Force: true,
                })
                if( err != nil) {
                    log.Error("Coundn't remove container: ", container.ID, ": ", err.Error())
                    return
                }
                log.Debug("Removed container with ID ", container.ID)
            }()
        }
        log.Debug("Created container with ID ", container.ID)

        log.Debug("About to start and attach to container with following options: ",
            "\nBinds: ", dockerHostConfig.Binds,
            "\nPortBindings: ", dockerHostConfig.PortBindings,
            "\nPrivileged: ", dockerHostConfig.Privileged,
            "\nSecurityOpt: ", dockerHostConfig.SecurityOpt,
            "\nDevices: ", dockerHostConfig.Devices,
            "\nUTSMode: ", dockerHostConfig.UTSMode,
            "\nNetworkMode: ", dockerHostConfig.NetworkMode,

            "\nImage: ", dockerConfig.Image,
            "\nCmd: ", dockerConfig.Cmd,
            "\nWorkingDir: ", dockerConfig.WorkingDir,
            "\nEnv: ", dockerConfig.Env,
            "\nExposedPorts: ", dockerConfig.ExposedPorts,
            "\nVolumeDriver: ", dockerConfig.VolumeDriver,
            "\nUser: ", dockerConfig.User,
            )

        //Try to start the container
        // if err = dockerpty.Start(client, container, &dockerHostConfig); err != nil {  // HostConfig is deprecated: https://github.com/fsouza/go-dockerclient/issues/537
        if err = dockerpty.Start(client, container, nil); err != nil {
            log.Error("Error while starting container, and attaching to it: ", err.Error(),
                "\nBinds: ", dockerHostConfig.Binds,
                "\nPortBindings: ", dockerHostConfig.PortBindings,
                "\nPrivileged: ", dockerHostConfig.Privileged,
                "\nSecurityOpt: ", dockerHostConfig.SecurityOpt,
                "\nDevices: ", dockerHostConfig.Devices,
                "\nUTSMode: ", dockerHostConfig.UTSMode,
                "\nNetworkMode: ", dockerHostConfig.NetworkMode,

                "\nImage: ", dockerConfig.Image,
                "\nCmd: ", dockerConfig.Cmd,
                "\nWorkingDir: ", dockerConfig.WorkingDir,
                "\nEnv: ", dockerConfig.Env,
                "\nExposedPorts: ", dockerConfig.ExposedPorts,
                "\nVolumeDriver: ", dockerConfig.VolumeDriver,
                "\nUser: ", dockerConfig.User,
                )
            return
        } else {
            // And once it is done with all the commands, remove the container.
            defer func () {
                err = client.StopContainer(container.ID, 0)
                if( err != nil) {
                    log.Debug("Could not stop container ", container.ID, ": ", err.Error())
                    return
                }
                log.Debug("Stopped container with ID ", container.ID)
            }()
        }
        log.Debug("Started container with ID ", container.ID)
    }
}

func execMacro(macro Config.Macro, context Utils.Context, useDockerCLI bool) {
    execInContainer(Config.GetActions(macro), macro, context, useDockerCLI)
}

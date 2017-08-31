package config

import(
    "path/filepath"
    Utils "github.com/matthieudelaro/nut/utils"
    containerFilepath "github.com/matthieudelaro/nut/container/filepath"

    log "github.com/Sirupsen/logrus"
    "errors"
    "strings"
)

type VolumeV7 struct {
    VolumeBase `yaml:"inheritedValues,inline"`

    VolumeName string `yaml:"volume_name,omitempty"`
    Host string `yaml:"host_path,omitempty"`
    Container string `yaml:"container_path"`
    Options string `yaml:"options,omitempty"`
}
        func (self *VolumeV7) getVolumeName() string {
            return self.VolumeName
        }
        func (self *VolumeV7) getOptions() string {
            return self.Options
        }
        // TODO: move the content of the two next function to an appropriate place
        // Same for V6 and V5
        func (self *VolumeV7) getFullHostPath(context Utils.Context) (string, error) {
            if self.Host == "" {
                return "", errors.New("Undefined host path")
            } else {
                // log.Debug("getFullHostPath value ", self.Host)
                res := filepath.Clean(self.Host)
                // log.Debug("getFullHostPath clean ", res)
                if !filepath.IsAbs(res) {
                    // log.Debug("getFullHostPath is not Abs")
                    res = filepath.Join(context.GetRootDirectory(), res)
                }
                // log.Debug("getFullHostPath value ", res)
                if strings.Contains(res, `:\`) { // path on windows. Eg: C:\\Users\
                    // log.Debug("getFullHostPath windows ", `:\`)
                    parts := strings.Split(res, `:\`)
                    parts[0] = strings.ToLower(parts[0]) // drive letter should be lower case
                    res = "//" + parts[0] + "/" + filepath.ToSlash(parts[1])
                }

                log.Debug("getFullHostPath res ", res)
                return res, nil
            }
        }
        func (self *VolumeV7) getFullContainerPath(context Utils.Context) (string, error) {
            if self.Container == "" {
                return "", errors.New("Undefined container path")
            } else {
                // log.Debug("getFullContainerPath value ", self.Container)
                clean := containerFilepath.ToSlash(containerFilepath.Clean(self.Container))
                // log.Debug("getFullContainerPath clean ", clean)
                if containerFilepath.IsAbs(clean) {
                    // log.Debug("getFullContainerPath isAbs")
                    return clean, nil
                } else {
                    // log.Debug("getFullContainerPath is not Abs")
                    log.Debug("getFullContainerPath return ", containerFilepath.Join(context.GetRootDirectory(), clean))
                    return containerFilepath.Join(context.GetRootDirectory(), clean), nil
                }
            }
        }


type DeviceV7 struct {
    DeviceBase `yaml:"inheritedValues,inline"`

    Host string `yaml:"host_path"`
    Container string `yaml:"container_path"`
    Options string `yaml:"options,omitempty"`
}
        func (self *DeviceV7) getHostPath() string {
            return self.Host
        }
        func (self *DeviceV7) getContainerPath() string {
            return self.Container
        }
        func (self *DeviceV7) getOptions() string {
            return self.Options
        }


type BaseEnvironmentV7 struct {
    BaseEnvironmentBase `yaml:"inheritedValues,inline"`

    FilePath string `yaml:"nut_file_path,omitempty"`
    GitHub string `yaml:"github,omitempty"`
}
        func (self *BaseEnvironmentV7) getFilePath() string{
            return self.FilePath
        }
        func (self *BaseEnvironmentV7) getGitHub() string{
            return self.GitHub
        }

type ConfigV7 struct {
    ConfigBase `yaml:"inheritedValues,inline"`

    DockerImage string `yaml:"docker_image,omitempty"`
    Volumes map[string]*VolumeV7 `yaml:"volumes,omitempty"`
    WorkingDir string `yaml:"container_working_directory,omitempty"`
    EnvironmentVariables map[string]string `yaml:"environment,omitempty"`
    Ports []string `yaml:"ports,omitempty"`
    EnableGUI string `yaml:"enable_gui,omitempty"`
    EnableNvidiaDevices string `yaml:"enable_nvidia_devices,omitempty"`
    Privileged string `yaml:"privileged,omitempty"`
    SecurityOpts []string `yaml:"security_opts,omitempty"`
    Detached string `yaml:"detached,omitempty"`
    UTSMode string `yaml:"uts,omitempty"`
    NetworkMode string `yaml:"net,omitempty"`
    Devices map[string]*DeviceV7 `yaml:"devices,omitempty"`
    EnableCurrentUser string `yaml:"enable_current_user,omitempty"`
    WorkInProjectFolderAs string `yaml:"work_in_project_folder_as,omitempty"`
    parent Config
}
        func (self *ConfigV7) getDockerImage() string {
            return self.DockerImage
        }
        func (self *ConfigV7) getNetworkMode() string {
            return self.NetworkMode
        }
        func (self *ConfigV7) getUTSMode() string {
            return self.UTSMode
        }
        func (self *ConfigV7) getParent() Config {
            return self.parent
        }
        func (self *ConfigV7) getWorkingDir() string {
            return self.WorkingDir
        }
        func (self *ConfigV7) getVolumes() map[string]Volume {
            cacheVolumes := make(map[string]Volume)
            for name, data := range(self.Volumes) {
                cacheVolumes[name] = data
            }
            return cacheVolumes
        }
        func (self *ConfigV7) getEnvironmentVariables() map[string]string {
            return self.EnvironmentVariables
        }
        func (self *ConfigV7) getDevices() map[string]Device {
            cacheVolumes := make(map[string]Device)
            for name, data := range(self.Devices) {
                cacheVolumes[name] = data
            }
            return cacheVolumes
        }
        func (self *ConfigV7) getPorts() []string {
            return self.Ports
        }
        func (self *ConfigV7) getEnableGui() (bool, bool) {
            return TruthyString(self.EnableGUI)
        }
        func (self *ConfigV7) getEnableNvidiaDevices() (bool, bool) {
            return TruthyString(self.EnableNvidiaDevices)
        }
        func (self *ConfigV7) getPrivileged() (bool, bool) {
            return TruthyString(self.Privileged)
        }
        func (self *ConfigV7) getDetached() (bool, bool) {
            return TruthyString(self.Detached)
        }
        func (self *ConfigV7) getEnableCurrentUser() (bool, bool) {
            return TruthyString(self.EnableCurrentUser)
        }
        func (self *ConfigV7) getSecurityOpts() []string {
            return self.SecurityOpts
        }
        func (self *ConfigV7) getWorkInProjectFolderAs() string {
            return self.WorkInProjectFolderAs
        }

type ProjectV7 struct {
    SyntaxVersion string `yaml:"syntax_version"`
    ProjectName string `yaml:"project_name"`
    Base BaseEnvironmentV7 `yaml:"based_on,omitempty"`
    Macros map[string]*MacroV7 `yaml:"macros,omitempty"`
    parent Project

    ProjectBase `yaml:"inheritedValues,inline"`
    ConfigV7 `yaml:"inheritedValues,inline"`
}
        func (self *ProjectV7) getSyntaxVersion() string {
            return self.SyntaxVersion
        }
        func (self *ProjectV7) getProjectName() string {
            return self.ProjectName
        }
        func (self *ProjectV7) getBaseEnv() BaseEnvironment {
            return &self.Base
        }
        func (self *ProjectV7) getMacros() map[string]Macro {
            // make the list of macros
            cacheMacros := make(map[string]Macro)
            for name, data := range self.Macros {
                data.parent = self
                cacheMacros[name] = data
            }
            return cacheMacros
        }
        // func (self *ProjectV7) createMacro(usage string, commands []string) Macro {
        //     return &MacroV7 {
        //         ConfigV7: *NewConfigV7(self,),
        //         Usage: usage,
        //         Actions: commands,
        //     }
        // }
        func (self *ProjectV7) getParent() Config {
            return self.parent
        }
        func (self *ProjectV7) getParentProject() Project {
            return self.parent
        }
        func (self *ProjectV7) setParentProject(project Project) {
            self.parent = project
        }

type MacroV7 struct {
    // A short description of the usage of this macro
    Usage string `yaml:"usage,omitempty"`
    // The commands to execute when this macro is invoked
    Actions []string `yaml:"actions,omitempty"`
    // A list of aliases for the macro
    Aliases []string `yaml:"aliases,omitempty"`
    // Custom text to show on USAGE section of help
    UsageText string `yaml:"usage_for_help_section,omitempty"`
    // A longer explanation of how the macro works
    Description string `yaml:"description,omitempty"`

    MacroBase `yaml:"inheritedValues,inline"`
    ConfigV7 `yaml:"inheritedValues,inline"`
}
        func (self *MacroV7) setParentProject(project Project) {
            self.ConfigV7.parent = project
        }
        func (self *MacroV7) getUsage() string {
            return self.Usage
        }
        func (self *MacroV7) getActions() []string {
            return self.Actions
        }
        func (self *MacroV7) getAliases() []string {
            return self.Aliases
        }
        func (self *MacroV7) getUsageText() string {
            return self.UsageText
        }
        func (self *MacroV7) getDescription() string {
            return self.Description
        }


func NewConfigV7(parent Config) *ConfigV7 {
    return &ConfigV7{
        Volumes: make(map[string]*VolumeV7),
        Devices: make(map[string]*DeviceV7),
        EnvironmentVariables: map[string]string{},
        parent: parent,
    }
}

func NewProjectV7(parent Project) *ProjectV7 {
    project := &ProjectV7 {
        SyntaxVersion: "7",
        Macros: make(map[string]*MacroV7),
        ConfigV7: *NewConfigV7(nil),
        parent: parent,
    }
    return project
}

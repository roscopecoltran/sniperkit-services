// Consumes the REST API exposed by nvidia-docker-plugin.
// See https://github.com/NVIDIA/nvidia-docker/wiki/Using-nvidia-docker-plugin#rest-api
package nvidia

import (
    "errors"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "net"
    "net/http"
    "net/url"
    "os"
    "strings"
    "syscall"
    "time"

    "golang.org/x/crypto/ssh"
    "golang.org/x/crypto/ssh/agent"
    "golang.org/x/crypto/ssh/terminal"
)

const timeout = 10 * time.Second
var ErrInvalidURI = errors.New("invalid remote host URI")

const (
    endpointInfo = "http://plugin/gpu/info/json"
    endpointCLI  = "http://plugin/docker/cli"
)

// Return the list of GPUs, the driverName (--volume-driver), and the driverVolume (--volume)
// by consuming nvidia-docker-plugin REST API.
// (--device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia0 --volume-driver=nvidia-docker --volume=nvidia_driver_352.63:/usr/local/nvidia:ro)
func GetConfiguration() (devices []string, driverName string, driverVolume string, err error) {
    devices = []string{}
    driverName = ""
    driverVolume = ""

    Host, _ := getHost()
    c := httpClient(Host)

    r, err := c.Get("http://v1.0/docker/cli")
    if err != nil {
        return
    }
    defer r.Body.Close()
    var bytes []byte
    if bytes, err = ioutil.ReadAll(r.Body); err == nil {
        // turn "--device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia0 --volume-driver=nvidia-docker --volume=nvidia_driver_352.63:/usr/local/nvidia:ro"
        // into "[ device=/dev/nvidiactl device=/dev/nvidia-uvm device=/dev/nvidia0 volume-driver=nvidia-docker volume=nvidia_driver_352.63:/usr/local/nvidia:ro]"
        args := strings.Split(" " + string(bytes), " --")
        for _, arg := range args {
            if arg != "" {
                // turn "device=/dev/nvidiactl" into [ device /dev/nvidiactl]
                keyValue := strings.Split(arg, "=")
                if len(keyValue) != 2 {
                    err = errors.New("Could not parse '=' from string: " + arg)
                }
                if keyValue[0] == "device" {
                    devices = append(devices, keyValue[1])
                } else if keyValue[0] == "volume-driver" {
                    driverName = keyValue[1]
                } else if keyValue[0] == "volume" {
                    driverVolume = keyValue[1]
                } else {
                    errors.New("Could not parse argument: " + arg)
                }
            }
        }
        return
    } else {
        return
    }
}

func GetDevices() ([]string, error) {
    var info struct {
        Version struct {
            Driver string
            CUDA string
        }
        Devices []struct {
            Model string
            Path string
        }
    }

    Host, _ := getHost()
    c := httpClient(Host)

    r, err := c.Get("http://v1.0/gpu/info/json")
    if err != nil {
        return nil, err
    }
    defer r.Body.Close()
    if err := json.NewDecoder(r.Body).Decode(&info); err != nil {
        return nil, err
    }
    list := []string{}
    for _, device := range info.Devices {
        list = append(list, device.Path)
    }
    return list, nil
}

func getHost() (*url.URL, error) {
    env := "http://localhost:3476/"
    uri, err := url.Parse(env)
    if err != nil {
        return nil, ErrInvalidURI
    } else {
        return uri, nil
    }
}

func httpClient(addr *url.URL) *http.Client {
    dial := func(string, string) (net.Conn, error) {
        if addr.Scheme == "ssh" {
            c, err := ssh.Dial("tcp", addr.Host, &ssh.ClientConfig{
                User: addr.User.Username(),
                Auth: sshAuths(addr),
            })
            if err != nil {
                return nil, err
            }
            return c.Dial("tcp", addr.Opaque)
        }
        return net.Dial("tcp", addr.Host)
    }

    return &http.Client{
        Timeout:   timeout,
        Transport: &http.Transport{Dial: dial},
    }
}

func sshAuths(addr *url.URL) (methods []ssh.AuthMethod) {
    if sock := os.Getenv("SSH_AUTH_SOCK"); sock != "" {
        c, err := net.Dial("unix", sock)
        if err != nil {
            log.Println("Warning: failed to contact the local SSH agent")
        } else {
            auth := ssh.PublicKeysCallback(agent.NewClient(c).Signers)
            methods = append(methods, auth)
        }
    }
    auth := ssh.PasswordCallback(func() (string, error) {
        fmt.Printf("%s@%s password: ", addr.User.Username(), addr.Host)
        b, err := terminal.ReadPassword(int(syscall.Stdin))
        fmt.Print("\n")
        return string(b), err
    })
    methods = append(methods, auth)
    return
}

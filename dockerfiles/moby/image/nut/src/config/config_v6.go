package config

import(
    "path/filepath"
    Utils "github.com/matthieudelaro/nut/utils"
    containerFilepath "github.com/matthieudelaro/nut/container/filepath"

    log "github.com/Sirupsen/logrus"
    "strings"
    "errors"
)

type VolumeV6 struct {
    VolumeBase `yaml:"inheritedValues,inline"`

    Host string `yaml:host_path`
    Container string `yaml:container_path`
}
        func (self *VolumeV6) getFullHostPath(context Utils.Context) (string, error) {
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
        func (self *VolumeV6) getFullContainerPath(context Utils.Context) (string, error) {
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

type BaseEnvironmentV6 struct {
    BaseEnvironmentBase `yaml:"inheritedValues,inline"`

    FilePath string `yaml:"nut_file_path,omitempty"`
    GitHub string `yaml:"github,omitempty"`
}
        func (self *BaseEnvironmentV6) getFilePath() string{
            return self.FilePath
        }
        func (self *BaseEnvironmentV6) getGitHub() string{
            return self.GitHub
        }

type ConfigV6 struct {
    ConfigBase `yaml:"inheritedValues,inline"`

    DockerImage string `yaml:"docker_image,omitempty"`
    Mount map[string][]string `yaml:"mount,omitempty"`
    WorkingDir string `yaml:"container_working_directory,omitempty"`
    EnvironmentVariables map[string]string `yaml:"environment,omitempty"`
    Ports []string `yaml:"ports,omitempty"`
    EnableGUI string `yaml:"enable_gui,omitempty"`
    EnableNvidiaDevices string `yaml:"enable_nvidia_devices,omitempty"`
    Privileged string `yaml:"privileged,omitempty"`
    SecurityOpts []string `yaml:"security_opts,omitempty"`
    parent Config
}
        func (self *ConfigV6) getDockerImage() string {
            return self.DockerImage
        }
        func (self *ConfigV6) getParent() Config {
            return self.parent
        }
        func (self *ConfigV6) getWorkingDir() string {
            return self.WorkingDir
        }
        func (self *ConfigV6) getVolumes() map[string]Volume {
            cacheVolumes := make(map[string]Volume)
            for name, data := range(self.Mount) {
                cacheVolumes[name] = &VolumeV6{
                    Host: data[0],
                    Container: data[1],
                }
            }
            return cacheVolumes
        }
        func (self *ConfigV6) getEnvironmentVariables() map[string]string {
            return self.EnvironmentVariables
        }
        func (self *ConfigV6) getPorts() []string {
            return self.Ports
        }
        func (self *ConfigV6) getEnableGui() (bool, bool) {
            return TruthyString(self.EnableGUI)
        }
        func (self *ConfigV6) getEnableNvidiaDevices() (bool, bool) {
            return TruthyString(self.EnableNvidiaDevices)
        }
        func (self *ConfigV6) getPrivileged() (bool, bool) {
            return TruthyString(self.Privileged)
        }
        func (self *ConfigV6) getSecurityOpts() []string {
            return self.SecurityOpts
        }

type ProjectV6 struct {
    SyntaxVersion string `yaml:"syntax_version"`
    ProjectName string `yaml:"project_name"`
    Base BaseEnvironmentV6 `yaml:"based_on,omitempty"`
    Macros map[string]*MacroV6 `yaml:"macros,omitempty"`
    parent Project

    ProjectBase `yaml:"inheritedValues,inline"`
    ConfigV6 `yaml:"inheritedValues,inline"`
}
        func (self *ProjectV6) getSyntaxVersion() string {
            return self.SyntaxVersion
        }
        func (self *ProjectV6) getProjectName() string {
            return self.ProjectName
        }
        func (self *ProjectV6) getBaseEnv() BaseEnvironment {
            return &self.Base
        }
        func (self *ProjectV6) getMacros() map[string]Macro {
            // make the list of macros
            cacheMacros := make(map[string]Macro)
            for name, data := range self.Macros {
                data.parent = self
                cacheMacros[name] = data
            }
            return cacheMacros
        }
        // func (self *ProjectV6) createMacro(usage string, commands []string) Macro {
        //     return &MacroV6 {
        //         ConfigV6: *NewConfigV6(self,),
        //         Usage: usage,
        //         Actions: commands,
        //     }
        // }
        func (self *ProjectV6) getParent() Config {
            return self.parent
        }
        func (self *ProjectV6) getParentProject() Project {
            return self.parent
        }
        func (self *ProjectV6) setParentProject(project Project) {
            self.parent = project
        }

type MacroV6 struct {
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
    ConfigV6 `yaml:"inheritedValues,inline"`
}
        func (self *MacroV6) setParentProject(project Project) {
            self.ConfigV6.parent = project
        }
        func (self *MacroV6) getUsage() string {
            return self.Usage
        }
        func (self *MacroV6) getActions() []string {
            return self.Actions
        }
        func (self *MacroV6) getAliases() []string {
            return self.Aliases
        }
        func (self *MacroV6) getUsageText() string {
            return self.UsageText
        }
        func (self *MacroV6) getDescription() string {
            return self.Description
        }


func NewConfigV6(parent Config) *ConfigV6 {
    return &ConfigV6{
        Mount: make(map[string][]string),
        EnvironmentVariables: map[string]string{},
        parent: parent,
    }
}

func NewProjectV6(parent Project) *ProjectV6 {
    project := &ProjectV6 {
        SyntaxVersion: "6",
        Macros: make(map[string]*MacroV6),
        ConfigV6: *NewConfigV6(nil),
        parent: parent,
    }
    return project
}

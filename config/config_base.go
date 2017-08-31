package config

import (
    containerFilepath "github.com/matthieudelaro/nut/container/filepath"
)

type VolumeBase struct {
}
        func (self *VolumeBase) getVolumeName() string {
            return ""
        }
        func (self *VolumeBase) getOptions() string {
            return ""
        }

type DeviceBase struct {
}
        func (self *DeviceBase) getHostPath() string {
            return ""
        }
        func (self *DeviceBase) getContainerPath() string {
            return ""
        }
        func (self *DeviceBase) getOptions() string {
            return ""
        }

type BaseEnvironmentBase struct {
}
        func (self *BaseEnvironmentBase) getFilePath() string{
            return ""
        }
        func (self *BaseEnvironmentBase) getGitHub() string{
            return ""
        }

type ConfigBase struct {
}
        func (self *ConfigBase) getDockerImage() string {
            return ""
        }
        func (self *ConfigBase) getProjectName() string {
            return ""
        }
        func (self *ConfigBase) getUTSMode() string {
            return ""
        }
        func (self *ConfigBase) getNetworkMode() string {
            return ""
        }
        func (self *ConfigBase) getParent() Config {
            return nil
        }
        func (self *ConfigBase) getSyntaxVersion() string {
            return ""
        }
        func (self *ConfigBase) getBaseEnv() BaseEnvironment {
            return nil
        }
        func (self *ConfigBase) getWorkingDir() string {
            str, _ := containerFilepath.Abs(".")
            return str
        }
        func (self *ConfigBase) getVolumes() map[string]Volume {
            return make(map[string]Volume)
        }
        func (self *ConfigBase) getMacros() map[string]Macro {
            return make(map[string]Macro)
        }
        func (self *ConfigBase) getEnvironmentVariables() map[string]string {
            return make(map[string]string)
        }
        func (self *ConfigBase) getDevices() map[string]Device {
            return make(map[string]Device)
        }
        func (self *ConfigBase) getPorts() []string {
            return []string{}
        }
        func (self *ConfigBase) getEnableGui() (bool, bool) {
            return false, false
        }
        func (self *ConfigBase) getEnableNvidiaDevices() (bool, bool)  {
            return false, false
        }
        func (self *ConfigBase) getPrivileged() (bool, bool)  {
            return false, false
        }
        func (self *ConfigBase) getDetached() (bool, bool)  {
            return false, false
        }
        func (self *ConfigBase) getEnableCurrentUser() (bool, bool)  {
            return false, false
        }
        func (self *ConfigBase) getSecurityOpts() []string {
            return []string{}
        }
        func (self *ConfigBase) getWorkInProjectFolderAs() string {
            return ""
        }

type ProjectBase struct {
}
        func (self *ProjectBase) getParentProject() Project {
            return nil
        }

type MacroBase struct {
}
        func (self *MacroBase) getUsage() string {
            return ""
        }
        func (self *MacroBase) getActions() []string {
            return []string{}
        }
        func (self *MacroBase) getAliases() []string {
            return []string{}
        }
        func (self *MacroBase) getUsageText() string {
            return ""
        }
        func (self *MacroBase) getDescription() string {
            return ""
        }

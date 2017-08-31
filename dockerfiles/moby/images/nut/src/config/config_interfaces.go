package config

import (
    Utils "github.com/matthieudelaro/nut/utils"
)

type Bind interface {
    getOptions() (string)
}
type Volume interface {
    getVolumeName() string
    getFullHostPath(context Utils.Context) (string, error)
    getFullContainerPath(context Utils.Context) (string, error)

    // implement Bind
    getOptions() (string)
}
type Device interface {
    getHostPath() string
    getContainerPath() string

    // implement Bind
    getOptions() (string)
}
type BaseEnvironment interface {
    getFilePath() string
    getGitHub() string
}

type Config interface {
    getDockerImage() string
    getProjectName() string
    getNetworkMode() string
    getUTSMode() string
    getParent() Config
    getSyntaxVersion() string
    getBaseEnv() BaseEnvironment
    getWorkingDir() string
    getVolumes() map[string]Volume
    getMacros() map[string]Macro
    getEnvironmentVariables() map[string]string
    getDevices() map[string]Device
    getPorts() []string
    getEnableGui() (bool, bool)
    getEnableNvidiaDevices() (bool, bool)
    getPrivileged() (bool, bool)
    getDetached() (bool, bool)
    getEnableCurrentUser() (bool, bool)
    getSecurityOpts() []string
    getWorkInProjectFolderAs() string
}
type Project interface { // extends Config interface
    // pure Project methods
    // createMacro(name string, commands []string) Macro
    setParentProject(project Project)

    // Config methods
    getDockerImage() string
    getProjectName() string
    getNetworkMode() string
    getUTSMode() string
    getParent() Config
    getParentProject() Project
    getSyntaxVersion() string
    getBaseEnv() BaseEnvironment
    getWorkingDir() string
    getVolumes() map[string]Volume
    getMacros() map[string]Macro
    getEnvironmentVariables() map[string]string
    getDevices() map[string]Device
    getPorts() []string
    getEnableGui() (bool, bool)
    getEnableNvidiaDevices() (bool, bool)
    getPrivileged() (bool, bool)
    getDetached() (bool, bool)
    getEnableCurrentUser() (bool, bool)
    getSecurityOpts() []string
    getWorkInProjectFolderAs() string

}
type Macro interface { // extends Config interface
    // pure Macro methods
    setParentProject(project Project)
    getUsage() string
    getActions() []string
    getAliases() []string
    getUsageText() string
    getDescription() string

    // Config methods
    getDockerImage() string
    getProjectName() string
    getNetworkMode() string
    getUTSMode() string
    getParent() Config
    getSyntaxVersion() string
    getBaseEnv() BaseEnvironment
    getWorkingDir() string
    getVolumes() map[string]Volume
    getMacros() map[string]Macro
    getEnvironmentVariables() map[string]string
    getDevices() map[string]Device
    getPorts() []string
    getEnableGui() (bool, bool)
    getEnableNvidiaDevices() (bool, bool)
    getPrivileged() (bool, bool)
    getDetached() (bool, bool)
    getEnableCurrentUser() (bool, bool)
    getSecurityOpts() []string
    getWorkInProjectFolderAs() string
}


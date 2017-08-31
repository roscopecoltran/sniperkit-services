package config

import (
    // log "github.com/Sirupsen/logrus"
    Utils "github.com/matthieudelaro/nut/utils"
)

// Define methods over interfaces
func GetHostPath(volume Device) string {
    return volume.getHostPath()
}
func GetContainerPath(volume Device) string {
    return volume.getContainerPath()
}
func GetOptions(bind Bind) string {
    return bind.getOptions()
}

func GetVolumeName(volume Volume) string {
    return volume.getVolumeName()
}
func GetFullHostPath(volume Volume, context Utils.Context) (string, error) {
    return volume.getFullHostPath(context)
}
func GetFullContainerPath(volume Volume, context Utils.Context) (string, error) {
    return volume.getFullContainerPath(context)
}

func SetParentProject(child Project, parent Project) {
    child.setParentProject(parent)
}

func GetUsage(macro Macro) string {
    return macro.getUsage()
}
func GetActions(macro Macro) []string {
    return macro.getActions()
}
func GetAliases(macro Macro) []string {
    return macro.getAliases()
}
func GetUsageText(macro Macro) string {
    return macro.getUsageText()
}
func GetDescription(macro Macro) string {
    return macro.getDescription()
}

func GetParent(config Config) Config {
    return config.getParent()
}

func GetDockerImage(config Config) string {
    if item := config.getDockerImage(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetDockerImage(parent)
    } else {
        return ""
    }
}

func GetNetworkMode(config Config) string {
    if item := config.getNetworkMode(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetNetworkMode(parent)
    } else {
        return ""
    }
}

func GetUTSMode(config Config) string {
    if item := config.getUTSMode(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetUTSMode(parent)
    } else {
        return ""
    }
}

func GetSyntaxVersion(config Config) string {
    if item := config.getSyntaxVersion(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetSyntaxVersion(parent)
    } else {
        return ""
    }
}

func GetBaseEnv(config Config) BaseEnvironment {
    if item := config.getBaseEnv(); item != nil {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetBaseEnv(parent)
    } else {
        return nil
    }
}

func GetWorkingDir(config Config) string {
    if item := config.getWorkingDir(); item != "" {
        return item
    } else if item := config.getWorkInProjectFolderAs(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetWorkingDir(parent)
    } else {
        return ""
    }

    // if config.getWorkingDir() == "" && config.getParent() != nil {
    //     return GetWorkingDir(config.getParent())
    // } else {
    //     return config.getWorkingDir()
    // }
}

func GetVolumes(config Config, context Utils.Context) map[string]Volume {
    items := config.getVolumes()
    if items == nil {
        items = map[string]Volume{}
    }

    // add project folder if need be, and if there is no conflict
    if destination := config.getWorkInProjectFolderAs(); destination != "" {
        // check that there is no conflict with explicit volumes, and add the
        // project's root folder as a volume if there is not conflict.
        projectFolderVolume := &VolumeV7 {
            VolumeName: "",
            Host: context.GetRootDirectory(),
            Container: destination,
            Options: "",
        }
        if conflict := CheckConflict(context, NutProjectFolderKey,
            projectFolderVolume, items); conflict == nil {
            items[NutProjectFolderKey] = projectFolderVolume
        }
    }

    // inherite volumes from parent
    if parent := config.getParent(); parent != nil {
        parentItems := GetVolumes(parent, context)
        for name, item := range parentItems {
            if CheckConflict(context, name, item, items) == nil {
                items[name] = item
            }
        }
    }

    return items
}

func GetMacros(config Project) map[string]Macro {
    items := config.getMacros()
    if items == nil {
        items = map[string]Macro{}
    }

    var parent = config.getParent()
    for parent != nil {
        for name, macro := range parent.getMacros() {
            if items[name] == nil {
                items[name] = macro
            }
        }
        parent = parent.getParent()
    }

    for _, macro := range items {
        macro.setParentProject(config)
    }
    return items
}

func GetEnvironmentVariables(config Config) map[string]string {
    items := config.getEnvironmentVariables()
    if items == nil {
        items = map[string]string{}
    }

    var parent = config.getParent()
    for parent != nil {
        for name, item := range parent.getEnvironmentVariables() {
            if _, ok := items[name]; !ok {
                items[name] = item
            }
        }
        parent = parent.getParent()
    }
    return items
}

func GetDevices(config Config) map[string]Device {
    items := config.getDevices()
    if items == nil {
        items = map[string]Device{}
    }

    var parent = config.getParent()
    for parent != nil {
        for name, item := range parent.getDevices() {
            if _, ok := items[name]; !ok {
                items[name] = item
            }
        }
        parent = parent.getParent()
    }
    return items
}

func GetPorts(config Config) []string {
    items := config.getPorts()

    var parent = config.getParent()
    for parent != nil {
        items = append(items, parent.getPorts()...)
        parent = parent.getParent()
    }
    return items
}

func GetSecurityOpts(config Config) []string {
    items := config.getSecurityOpts()

    var parent = config.getParent()
    for parent != nil {
        items = append(items, parent.getSecurityOpts()...)
        parent = parent.getParent()
    }
    return items
}

func IsGUIEnabled(config Config) bool {
    value, defined := config.getEnableGui()
    parent := config.getParent()
    if defined || parent == nil {
        return value
    } else {
        return IsGUIEnabled(parent)
    }
}

func IsNvidiaDevicesEnabled(config Config) bool {
    value, defined := config.getEnableNvidiaDevices()
    parent := config.getParent()
    if defined || parent == nil {
        return value
    } else {
        return IsNvidiaDevicesEnabled(parent)
    }
}

func IsPrivileged(config Config) bool {
    value, defined := config.getPrivileged()
    parent := config.getParent()
    if defined || parent == nil {
        return value
    } else {
        return IsPrivileged(parent)
    }
}

func IsDetached(config Config) bool {
    value, defined := config.getDetached()
    parent := config.getParent()
    if defined || parent == nil {
        return value
    } else {
        return IsDetached(parent)
    }
}

func IsCurrentUserEnabled(config Config) bool {
    value, defined := config.getEnableCurrentUser()
    parent := config.getParent()
    if defined || parent == nil {
        return value
    } else {
        return IsCurrentUserEnabled(parent)
    }
}

func GetProjectName(config Config) string {
    if item := config.getProjectName(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetProjectName(parent)
    } else {
        return ""
    }
}

func GetWorkInProjectFolderAs(config Config) string {
    if item := config.getWorkInProjectFolderAs(); item != "" {
        return item
    } else if parent := config.getParent(); parent != nil {
        return GetWorkInProjectFolderAs(parent)
    } else {
        return ""
    }
}

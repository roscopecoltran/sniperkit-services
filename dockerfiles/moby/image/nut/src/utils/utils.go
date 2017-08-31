package utils

import (
    "os"
    "time"
    "strings"
)

// Returns whether the given file or directory exists or not
func FileExists(path string) (bool, error) {
    _, err := os.Stat(path)
    if err == nil {
        return true, nil
    }
    if os.IsNotExist(err) {
        return false, nil
    }
    return true, err
}


// Get timezone and generate corresponding TZ environment
// variable value, such as "UTC-09:30"
// Useful for timezone feature: in order to synchronize the timezone
//     of the container with the one of the host, set the variable TZ.
//     (See http://www.cyberciti.biz/faq/linux-unix-set-tz-environment-variable/)
//     So, if TZ variable is not set in the configuration, then set
//     it to the host timezone information.
func GetTimezoneOffsetToTZEnvironmentVariableFormat() string {
    now := time.Now()
    // now.String: 2016-06-15 23:42:46.465743966 +0900 KST
    dateArray := strings.Fields(now.String())

    // get the offset and timezone
    offsetString := dateArray[2] // +0900
    sign := string(offsetString[0]) // +
    hours := string(offsetString[1]) + string(offsetString[2]) // 09
    minutes := string(offsetString[3]) + string(offsetString[4]) // 00

    TZ := "UTC"
    if sign == "+" {
        TZ += "-"
    } else {
        TZ += "+"
    }
    TZ += hours + ":" + minutes

    return TZ
}

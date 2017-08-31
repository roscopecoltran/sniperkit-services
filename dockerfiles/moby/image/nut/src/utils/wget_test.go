package utils

import (
    "testing"
    "os"
    "io/ioutil"
)

func TestWget(t *testing.T) {
    file, err := ioutil.TempFile(os.TempDir(), "testWgetNut")
    defer os.Remove(file.Name())

    err = Wget("https://raw.githubusercontent.com/matthieudelaro/nutfile_go1.5/master/nut.yml", file.Name())
    if err != nil {
        t.Error(
            err,
        )
    }
}

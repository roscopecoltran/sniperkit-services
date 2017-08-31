// persist package handles data saved for Nut, on the file system (in .nut/ folder)
package persist

import (
    // log "github.com/Sirupsen/logrus"
    "io/ioutil"
    "os"
    "errors"
    "path/filepath"
)

const FolderName = ".nut"
const EnvironmentsFolder = "environment"  // where nut files are stored

type Store interface {
    // returns the root path of the store
    GetPath() string
}

type StoreBase struct {
    path string
}
    func (self *StoreBase) GetPath() string {
        return self.path
    }

// Initialize the store on the hard drive if it does not
// exist yet, and return it. Throws if it couldn't create files.
func InitStore(path string) (Store, error) {
    _, err := os.Stat(path)
    store := &StoreBase {
        path: filepath.Join(path, FolderName),
    }
    if err != nil {
        err = os.MkdirAll(path, 0755) // TODO: discuss this permission level
        if err != nil {
            return nil, errors.New("Folder " + path +
                " does not exit, and could be created.")
        }

        environmentFolder := GetEnvironmentFolder(store)
        err = os.MkdirAll(environmentFolder, 0755) // TODO: discuss this permission level
        if err != nil {
            return nil, errors.New("Folder " + environmentFolder +
                " could be created.")
        }
    }
    return store, nil
}

// Remove the store from hard drive
func CleanStore(store Store) {
    os.RemoveAll(store.GetPath())
}

// Remove the store from hard drive
func CleanStoreFromProject(path string) {
    os.RemoveAll(filepath.Join(path, FolderName))
}

// Returns the path of the environment folder
func GetEnvironmentFolder(store Store) string {
    return filepath.Join(store.GetPath(), EnvironmentsFolder)
}

// stores a file, and returns its full name, and an error
func StoreFile(store Store, fileName string, data []byte) (string, error) {
    fullPath := filepath.Join(store.GetPath(), fileName)
    err := os.MkdirAll(filepath.Dir(fullPath), 0755) // TODO: discuss this permission level
    if err != nil {
        return "", errors.New("Folder " + filepath.Dir(fullPath) +
            " couldn't be created: " + err.Error())
    } else {
        err := ioutil.WriteFile(fullPath, []byte(data), 0755) // TODO: discuss this permission level
        return fullPath, err
    }
}

// Reads a file, and returns its content, its full name, and an error
func ReadFile(store Store, fileName string) ([]byte, string, error) {
    fullPath := filepath.Join(store.GetPath(), fileName)
    bytes, err := ioutil.ReadFile(fullPath)
    return bytes, fullPath, err
}

// // return a saved value
// // define for string, int, []string, []int
// func read(key, defaultValue) {}
// // save a value
// // define for several types
// func save(key) {}



package utils

import (
    "path/filepath"
)

/// Hold information about the context
/// in which nut has been called.
type Context interface {
    /// Returns the location of the project,
    /// aka where is the nut.yml file in use.
    /// Returned value is an absolute path.
    GetRootDirectory() string
    /// Returns the directory from which the
    /// user called Nut.
    /// Returned value is an absolute path.
    GetUserDirectory() string
}

type ContextBase struct {
    RootDirectory string
    UserDirectory string
}
        func (self *ContextBase) GetRootDirectory() string {
            return self.RootDirectory
        }
        func (self *ContextBase) GetUserDirectory() string {
            return self.UserDirectory
        }

func NewContext(rootDirectory string, userDirectory string) (Context, error) {
    r, errR := filepath.Abs(rootDirectory)
    u, errU := filepath.Abs(userDirectory)
    if errR != nil {
        return nil, errR
    }
    if errU != nil {
        return nil, errU
    }
    return &ContextBase{
        RootDirectory: r,
        UserDirectory: u,
    }, nil
}

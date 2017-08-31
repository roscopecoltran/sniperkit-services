package config

import (
    // "errors"
    log "github.com/Sirupsen/logrus"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "testing"
    "reflect"
    "strconv"
)


func TestFromNutPackage(t *testing.T) {
    log.SetLevel(log.DebugLevel)

    var volume Volume
    volume = &VolumeV6{}
    log.Debug("OK ", volume)

    var baseEnv BaseEnvironment
    baseEnv = &BaseEnvironmentBase{}
    baseEnv = &BaseEnvironmentV6{}
    log.Debug("OK ", baseEnv)

    var conf Config
    // conf = &ConfigBase{}
    // conf = &ProjectBase{}
    // conf = &ProjectBase{}
    conf = NewConfigV6(nil) // make sure that ConfigV6 implements Config
    log.Debug("OK ", conf)

    projV6 := NewProjectV6(nil)
    projV6.Macros = map[string]*MacroV6{
        "run": &MacroV6 {Usage: "run, from project",},
        "build": &MacroV6 {Usage: "build, from project",},
    }
    // *NewConfigV6(
    //         // "ProjectV6.WorkingDir",
    //         // []string{"ProjectV6.Ports"},
    //         nil,
    //     ),
    projV6.ProjectName = "NewNut"
    var proj Project
    proj = projV6
    conf = proj // make sure that Project implements Config
    log.Debug("OK ", proj)

    var macro Macro
    // macro = &MacroBase{}
    macro = &MacroV6{
        Usage: "UsageV6",
        ConfigV6: *NewConfigV6(
            // "MacroV6.WorkingDir",
            // []string{"MacroV6.Ports"},
            proj,
        ),
    }

    conf = macro // make sure that Macro implements Config
    log.Debug("OK ", macro)

    macros := GetMacros(proj)
    log.Debug("OK merge macros ", macros)

    ports := GetPorts(macro)
    log.Debug("OK merge ports ", ports)

    priv := IsPrivileged(macro)
    log.Debug("OK privileged ", priv)

    // macroExec := CreateMacro(proj, "--exec", []string{"echo hello"})
    // log.Debug("OK macroExec ", macroExec)
    log.Debug("proj before YAML ", proj)

//     bytes, err := yaml.Marshal(proj)
//     log.Debug("proj ", err, string(bytes))

//     input := `ports:
// - ProjectV6.Ports
// macros:
//   build:
//     usage: build, from project
//   run:
//     usage: run, from project`
//     err = yaml.Unmarshal([]byte(input), proj)
//     log.Debug("proj ", err, proj)
//     bytes, err = yaml.Marshal(proj)
//     log.Debug("proj ", err, string(bytes))
//     err = yaml.Unmarshal([]byte(input), proj)
//     log.Debug("proj ", err, proj)
}


type projectPair struct {
    p1 Project
    p2 Project
    res interface{}
}

func makeProject(name string, workingDir string, enableGui string) Project {
    p := NewProjectV6(nil)
    p.Mount["main"] = []string{".", "/go/src/project"}
    p.Macros["build"] = &MacroV6{
        Usage: "build the project",
        Actions: []string{"go build -o nut"},
    }
    p.ProjectName = name
    p.WorkingDir = workingDir
    p.EnableGUI = enableGui
    return p
}

func makeChild(name string, workingDir string, enableGui string) Project {
    return makeProject(name, workingDir, enableGui)
}
func makeParent(name string, workingDir string, enableGui string) Project {
    return makeProject(name, workingDir, enableGui)
}

func strToBool(str string) bool {
    if str == "true" {
        return true
    } else {
        return false
    }
}

func TestInheritanceEnableGui(t *testing.T) {
    possible := []string{"true", "false", "", "junk"}
    for _, vp := range possible {
        for _, vc := range possible {

            p1 := makeChild("child", "child", vc)
            p2 := makeParent("parent", "parent", vp)

            p1.setParentProject(p2)

            res := IsGUIEnabled(p1)
            var expectation bool
            if vc == "" {
                expectation = strToBool(vp)
            } else {
                expectation = strToBool(vc)
            }

            if res != expectation {
                t.Error(
                    "For", vc, vp,
                    "expected", expectation,
                    "got", res,
                )
            }
        }
    }
}

func TestInheritanceDockerImage(t *testing.T) {
    possible := []string{"", "golang:1.6", "golang:1.6"}
    for _, vp := range possible {
        for _, vc := range possible {
            pc := NewProjectV6(nil)
            pc.DockerImage = vc
            pp := NewProjectV6(nil)
            pp.DockerImage = vp

            pc.setParentProject(pp)

            res := GetDockerImage(pc)
            expectation := "undefined"
            if vc == "" {
                expectation = vp
            } else {
                expectation = vc
            }

            if res != expectation {
                t.Error(
                    "For child=", vc, "parent=", vp,
                    "expected", expectation,
                    "got", res,
                )
            }
        }
    }
}

func TestInheritanceWorkingDir(t *testing.T) {
    possible := []string{"here", "", "or here"}
    for _, vp := range possible {
        for _, vc := range possible {

            p1 := makeChild("child", vc, "child")
            p2 := makeParent("parent", vp, "parent")

            p1.setParentProject(p2)

            res := GetWorkingDir(p1)
            var expectation string
            if vc == "" {
                expectation = vp
            } else {
                expectation = vc
            }

            if res != expectation {
                t.Error(
                    "For", vc, vp,
                    "expected", expectation,
                    "got", res,
                )
            }
        }
    }
}

func TestInheritanceName(t *testing.T) {
    possible := []string{"name1", "", "name2"}
    for _, vp := range possible {
        for _, vc := range possible {

            p1 := makeChild(vc, "child", "child")
            p2 := makeParent(vp, "parent", "parent")

            p1.setParentProject(p2)

            res := GetProjectName(p1)
            var expectation string
            if vc == "" {
                expectation = vp
            } else {
                expectation = vc
            }

            if res != expectation {
                t.Error(
                    "For", vc, vp,
                    "expected", expectation,
                    "got", res,
                )
            }
        }
    }
}

func makeProjectMacros(macros []string, usage string) Project {
    p := NewProjectV6(nil)
    for _, name := range macros {
        p.Macros[name] = &MacroV6{
            Usage: usage,
            Actions: []string{name},
            ConfigV6: *NewConfigV6(p),
        }
    }
    return p
}

func macroInList(name string, list []string) bool {
    for _, b := range list {
        if b == name {
            return true
        }
    }
    return false
}

func TestInheritanceMacros(t *testing.T) {
    possible := [][]string{[]string{}, []string{"run"}, []string{"build"}, []string{"build", "run"}}
    for _, vp := range possible {
        for _, vc := range possible {

            pc := makeProjectMacros(vc, "child")
            pp := makeProjectMacros(vp, "parent")

            pc.setParentProject(pp)

            nameOccurences := make(map[string]int)
            for _, name := range append(vc, vp...) {
                nameOccurences[name] += 1
            }

            macrosc := GetMacros(pc)
            macrosp := GetMacros(pp)

            for name, count := range nameOccurences {
                if count == 2 {
                    // it must be in parent and in child
                    // and we expect the one of the child
                    if macrosc[name] == nil ||
                       macrosp[name] == nil ||
                       macrosc[name].getUsage() != "child" {
                        t.Error("Macro", name, "defined in parent and in child",
                            "expected to be overriden by the child")
                    }
                } else if count == 1 {
                    // it comes either from parent or from child
                    if macrosp[name] != nil {
                        if macrosp[name].getUsage() != "parent" {
                            t.Error("Macro", name, "defined in parent",
                                "expected to be overriden by the child")
                        }
                    } else if macrosc[name] != nil{
                        if macrosc[name].getUsage() != "child" {
                            t.Error("Macro", name, "defined in child",
                                "expected to be overriden by the child")
                        }
                    } else {
                        t.Error("Macro", name, "has been ignored.")
                    }
                }
            }
        }
    }
}

func TestParsingV6(t *testing.T) {
    log.SetLevel(log.DebugLevel)

    type Tuple struct {
        file string
        env map[string]string
        ports []string
        docker_image string
    }

    nutFiles := []Tuple{}

    nutFiles = append(nutFiles,
Tuple{ file:`
syntax_version: "6"
docker_image: golang:1.6
`,
ports: []string{},
docker_image: "golang:1.6",
},
Tuple{ file:`
syntax_version: "6"
docker_image: golang:1.6
environment:
  A: 1
  B: 2
`,
env: map[string]string{
    "A": "1",
    "B": "2",
}, ports: []string{},
docker_image: "golang:1.6",
},
Tuple{ file:`
syntax_version: "6"
docker_image: golang:1.6
environment:
  A: 1
  B:
ports:
  - "3000:3000"
  - 100:100
`,
env: map[string]string{
    "A": "1",
    "B": "",
}, ports: []string{
    "3000:3000",
    "100:100",
},
docker_image: "golang:1.6",
},
Tuple{ file:`
syntax_version: "6"
docker_image: golang:1.6
environment:
  A: 1
  B:
ports:
  - "3000:3000"
`,
env: map[string]string{
    "A": "1",
    "B": "",
}, ports: []string{
    "3000:3000",
},
docker_image: "golang:1.6",
},
)

    for index, tuple := range nutFiles {
        byteArray := []byte(tuple.file)
        // project := NewProjectV6(nil)
        project, err := ProjectFromYAML(byteArray)
        assert.NotNil(t, project)
        assert.Nil(t, err)

        assert.Equal(t, GetDockerImage(project), tuple.docker_image,
                "Error with tuple " + strconv.Itoa(index) + ": not same docker_image")

        envVariables := project.getEnvironmentVariables()
        assert.Equal(t, len(reflect.ValueOf(tuple.env).MapKeys()),
            len(reflect.ValueOf(envVariables).MapKeys()),
            "Error with tuple " + strconv.Itoa(index) + ": not same keys")

        for name, value := range envVariables {
            assert.Equal(t, value, tuple.env[name],
                "Error with tuple " + strconv.Itoa(index) + ": not same " + name)
            // execInContainer([]string{"echo $" + name}, project)
            // TODO: automate this test
        }

        ports := project.getPorts()
        require.Equal(t, len(tuple.ports), len(ports),
            "Error with tuple " + strconv.Itoa(index) + ": not same port quantity")
        for key, value := range ports {
            assert.Equal(t, value, tuple.ports[key],
                "Error with tuple " + strconv.Itoa(index) +
                ": not same port " + strconv.Itoa(key))
        }
    }

    // test nginx
    // TODO: automate this test
//     nutFile := `
// syntax_version: "6"
// based_on:
//   docker_image: nginx
// ports:
// #  - "80:80"  # works
//   - "80"  # works
// `
//     project := NewProjectV6()
//     byteArray := []byte(nutFile)
//     assert.Nil(t, project.fromYAML(byteArray))
//     execInContainer([]string{}, project)

//     log.Error("end")
}


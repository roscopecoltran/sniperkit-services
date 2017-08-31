### README
**This README needs to be updated.**

Nut must remain backward compatible with respect to nut configuration files.
It must also be easy to add new features in nut files, without issues of
performance to parse the file, and without applying modifications to all
older versions to insure backward compatibility.

The chosen solution is that new features should be defined in the interface,
and default behavior/feature should be defined in base class (to be
accessible) to all syntaxes version. Then override this default behavior in
the new syntax version.

 Interfaces Names| Base Class Names    | Version 2         | Version 3         | ...
 ----------------+---------------------+-------------------+-------------------+----
 Macro           | MacroBase           | MacroV2           | MacroV3           | ...
 MountingPoint   | MountingPointBase   | MountingPointV2   | MountingPointV3   | ...
 BaseEnvironment | BaseEnvironmentBase | BaseEnvironmentV2 | BaseEnvironmentV3 | ...
 Project         | ProjectBase         | ProjectV2         | ProjectV3         | ...

For each new syntax, copy/paste a project_vXXX.go file (ie the latest one)
and change implementation to suit new requirements.
For any new feature, create a virtual method in the interface Project
(or its components Macro, MountingPoint, BaseEnvironment, etc) and
implement a method in ProjectBase class (or its components MacroBase, etc)
to define a default behavior for older versions.

Old syntax versions should never be modified. Only the interface, the
base class, and the new syntax should be updated.

Note: When working with structs and embedding, everything is STATICALLY LINKED. All references are resolved at compile time.
See https://github.com/luciotato/golang-notes/blob/master/OOP.md for more details.

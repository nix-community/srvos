# Design

This page explains some of the design decisions that have been made trough
this project.

## `_file` attribute in the NixOS modules

You might see that all the NixOS modules in this repo have a `_file` attribute, which is quite uncommon to see. The reason we do this is to improve the error reporting whenever a type issue happens.

Normally that attribute is set by the recursive module `imports` traversal, when `imports` is a list of paths. The issue is that `nix flake check` expects all the modules attached to the `nixosModules` attributes to be functions and not paths. This forces us to use the `import` keyword, and that loses the reference to the path. So we add them back manually.

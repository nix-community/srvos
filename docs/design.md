# Design

This page explains some of the design decisions that have been made trough
this project.

## What are there `_file` attributes in the NixOS modules?

TL;DR: to provide better error reporting.

This is a bit of a subtle issue, combining knowlede about both Flakes and the Nix module system, so please hang with me.

First, there are two types of imports in the Nix ecosystem:

1. The `import` builtin function. This can be used anywhere in the code read a target Nix file, and return the evaluation result in its place.
2. The `imports` attribute in the Nix module system. This takes a list of either path, attr or function, which is then used to extend the module system with new option of config values.

The reason to add the `_file` attribute is that it's used to report when there are value or type clashes while building the config tree.
It helps the user be pointed directly to the right location. Typically, NixOS modules are passed as a path, and in that case, the module system transparently annotates the module with the `_file` attribute so you don't see it in most cases.

Now let's talk about flakes.

When running `nix flake check`, Nix expects the NixOS modules to sit in the `nixosModules.<name>` prefix. And that the value is a function. If we give it a path, it will fail the check. So we can't have a path to (2) and therefor need to use (1) and annotate the `_file` manually.

Case closed :)
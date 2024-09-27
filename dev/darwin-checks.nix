{
  inputs,
  prefix,
  self,
  pkgs,
}:
let
  lib = pkgs.lib;

  darwinConfigurations = import ./darwin-test-configurations.nix { inherit inputs self pkgs; };

  darwinChecks = lib.mapAttrs' (name: value: {
    name = "${prefix}-${name}";
    value = value.config.system.build.toplevel;
  }) (lib.filterAttrs (_name: value: value != null) darwinConfigurations);
in
darwinChecks

{ nixpkgs }:
let
  inherit (nixpkgs.lib) importJSON;

  nixosLib = (import "${nixpkgs}/nixos/lib") {
    # Experimental features need testing too, but there's no point in warning
    # about it, so we enable the feature flag.
    featureFlags.minimalModules = { };
  };

  importMod = jsonPath:
    map (name: "${nixpkgs}/nixos/modules/${name}") (importJSON jsonPath);

  # Very minimal list of modules for servers
  baseModules =
    (importMod ./module-list.json) ++
    (importMod ./module-needed.json);
in
# An alternative to nixpkgs.lib.nixosSystem, that only loads the list of modules that are strictly needed.
{ system, modules }:
nixosLib.evalModules {
  modules = [{
    config = {
      _module.args = {
        inherit baseModules;
      };
      nixpkgs = { inherit system; };
    };
  }] ++ baseModules ++ modules;
}

inputs @ { self, nixpkgs, ... }:
let
  lib = nixpkgs.lib;

  flake = import "${self}/flake.nix";

  # Default to all the systems supported by nixpkgs.
  supportedSystems = flake.systems or flake.nixConfig.supportedSystems or lib.systems.flakeExposed;

  forAllSystems = lib.genAttrs supportedSystems;
in
throw "TODO: magic here"

{
  description = "Server-optimized NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, self, ... }: {
      imports = [
        ./dev/vendor/flake-private-dev-inputs.nix
      ];
      config = {
        privateDevInputSubflakePath = "dev/private";
        partitionedAttrs = {
          checks = "dev";
          devShells = "dev";
          formatter = "dev";
          packages = "dev";
        };
        partitions.dev.settings = { inputs, ... }: {
          imports = [
            inputs.pre-commit-hooks-nix.flakeModule
            inputs.treefmt-nix.flakeModule
          ];
          perSystem = { config, lib, pkgs, self', system, ... }:
            let
              defaultPlatform = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
              inherit (pkgs.stdenv.hostPlatform) isLinux;
            in
            {
              checks =
                let
                  devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
                  packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
                in
                devShells // { inherit (self') formatter; } // packages //
                (lib.optionalAttrs isLinux (import ./dev/checks.nix {
                  inherit self pkgs lib system;
                  prefix = "nixos";
                }))
                // (lib.optionalAttrs isLinux (import ./dev/checks.nix {
                  inherit self system;
                  pkgs = import inputs.nixos-stable {
                    inherit system;
                  };
                  inherit (inputs.nixos-stable) lib;
                  prefix = "nixos-stable";
                }));

              devShells = {
                mkdocs = pkgs.mkShellNoCC {
                  packages = [
                    inputs.mkdocs-numtide.packages.${system}.default
                  ];
                };
              };
              packages = {
                update-dev-private-narHash = pkgs.writeScriptBin "update-dev-private-narHash"
                  "${config.pre-commit.settings.hooks.dev-private-narHash.entry}";
              } // lib.optionalAttrs defaultPlatform {
                docs = inputs.mkdocs-numtide.lib.${system}.mkDocs {
                  name = "srvos";
                  src = self;
                };
              };
              pre-commit = {
                check.enable = defaultPlatform;
              };
              treefmt = {
                flakeCheck = defaultPlatform;
                imports = [ ./dev/treefmt.nix ];
              };
            };
        };
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

        # generates future flake outputs: `modules.<kind>.<module-name>`
        flake.modules.nixos = import ./nixos;

        # compat to current schema: `nixosModules` / `darwinModules`
        flake.nixosModules = self.modules.nixos;
      };
    });
}

{
  description = "Server-optimized NixOS configuration";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs =
    publicInputs@{ self, nixpkgs, ... }:
    let
      loadPrivateFlake =
        path:
        let
          flakeHash = nixpkgs.lib.fileContents "${toString path}.narHash";
          flakePath = "path:${toString path}?narHash=${flakeHash}";
        in
        builtins.getFlake (builtins.unsafeDiscardStringContext flakePath);

      privateFlake = loadPrivateFlake ./dev/private;

      inputs = privateFlake.inputs // publicInputs;

      # Just the NixOS and Darwin modules
      modules = import ./.;
    in
    # builtins.getFlake is not available in flake-compat mode
    if builtins ? getFlake then
      inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          inputs.git-hooks-nix.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

        perSystem =
          {
            config,
            lib,
            pkgs,
            self',
            system,
            ...
          }:
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
              devShells
              // {
                inherit (self') formatter;
              }
              // packages
              // (lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") (
                import ./dev/darwin-checks.nix {
                  inherit inputs self pkgs;
                  prefix = "darwin";
                }
              ))
              // (lib.optionalAttrs isLinux (
                import ./dev/checks.nix {
                  inherit self pkgs;
                  prefix = "nixos";
                }
              ))
              // (lib.optionalAttrs isLinux (
                import ./dev/checks.nix {
                  inherit self;
                  pkgs = import inputs.nixos-stable { inherit system; };
                  prefix = "nixos-stable";
                }
              ));

            devShells = lib.optionalAttrs defaultPlatform {
              mkdocs = pkgs.mkShellNoCC { packages = [ inputs.mkdocs-numtide.packages.${system}.default ]; };
            };
            packages =
              {
                update-dev-private-narHash = pkgs.writeScriptBin "update-dev-private-narHash" ''
                  nix flake lock ./dev/private
                  nix hash path ./dev/private > ./dev/private.narHash
                '';
              }
              // lib.optionalAttrs defaultPlatform {
                docs = inputs.mkdocs-numtide.lib.${system}.mkDocs {
                  name = "srvos";
                  src = self;
                };
              };
            pre-commit = {
              check.enable = defaultPlatform;
              settings.hooks.dev-private-narHash = {
                enable = true;
                description = "dev-private-narHash";
                entry = "sh -c '${lib.getExe pkgs.nix} --extra-experimental-features nix-command hash path ./dev/private > ./dev/private.narHash'";
              };
            };
            treefmt = {
              flakeCheck = defaultPlatform;
              imports = [ ./dev/treefmt.nix ];
            };
          };

        # generates future flake outputs: `modules.<kind>.<module-name>`
        flake = modules;
      }
    else
      modules;
}

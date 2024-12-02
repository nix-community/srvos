{ self, inputs, ... }:
{
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
          import ./darwin-checks.nix {
            inherit inputs self pkgs;
            prefix = "darwin";
          }
        ))
        // (lib.optionalAttrs isLinux (
          import ./checks.nix {
            inherit self pkgs;
            prefix = "nixos";
          }
        ))
        // (lib.optionalAttrs isLinux (
          import ./checks.nix {
            inherit self;
            pkgs = import inputs.nixos-stable { inherit system; };
            prefix = "nixos-stable";
          }
        ));

      devShells = lib.optionalAttrs defaultPlatform {
        mkdocs = pkgs.mkShellNoCC { packages = [ inputs.mkdocs-numtide.packages.${system}.default ]; };
      };
      packages = lib.optionalAttrs defaultPlatform {
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
        imports = [ ./treefmt.nix ];
      };
    };
}

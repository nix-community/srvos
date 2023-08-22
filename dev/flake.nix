{
  description = "srvos dev flake";

  inputs.srvos.url = "path:../";

  inputs.nixpkgs.follows = "srvos/nixpkgs";

  inputs.nixos-23_05.url = "github:NixOS/nixpkgs/nixos-23.05";

  inputs.mkdocs-numtide.url = "github:numtide/mkdocs-numtide";
  inputs.mkdocs-numtide.inputs.nixpkgs.follows = "nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { nixpkgs, nixos-23_05, mkdocs-numtide, treefmt-nix, srvos, ... }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f:
        lib.genAttrs
          srvos.lib.supportedSystems
          (system: f nixpkgs.legacyPackages.${system});

      treefmtCfg = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      treefmt = eachSystem (pkgs: treefmtCfg.${pkgs.system}.config.build.wrapper);
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            mkdocs-numtide.packages.${pkgs.system}.default
            pkgs.nix-eval-jobs
            treefmt.${pkgs.system}
          ];
        };
      });

      packages = eachSystem (pkgs: {
        treefmt = treefmt.${pkgs.system};

        docs = mkdocs-numtide.lib.${pkgs.system}.mkDocs {
          name = "srvos";
          src = toString srvos;
        };
      });

      checks = eachSystem (pkgs:
        {
          treefmt = treefmtCfg.${pkgs.system}.config.build.check srvos;
        } // (lib.optionalAttrs pkgs.stdenv.isLinux (import ./checks.nix {
          inherit srvos nixpkgs;
          prefix = "nixos";
          system = pkgs.system;
        })) // (lib.optionalAttrs pkgs.stdenv.isLinux (import ./checks.nix {
          inherit srvos;
          nixpkgs = nixos-23_05;
          prefix = "nixos-23_05";
          system = pkgs.system;
        })));
    };
}

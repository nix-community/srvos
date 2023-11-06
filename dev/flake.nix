{
  description = "srvos dev flake";

  inputs.srvos.url = "path:../";

  inputs.nixpkgs.follows = "srvos/nixpkgs";

  inputs.mkdocs-numtide.url = "github:numtide/mkdocs-numtide";
  inputs.mkdocs-numtide.inputs.nixpkgs.follows = "nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { nixpkgs, mkdocs-numtide, treefmt-nix, srvos, ... }:
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
        });
    };
}

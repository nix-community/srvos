{
  description = "srvos dev flake";

  inputs.srvos.url = "path:../";

  inputs.nixpkgs.follows = "srvos/nixpkgs";

  inputs.mkdocs-numtide.url = "github:numtide/mkdocs-numtide";
  inputs.mkdocs-numtide.inputs.nixpkgs.follows = "nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { self, nixpkgs, mkdocs-numtide, treefmt-nix, srvos, ... }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs
          srvos.lib.supportedSystems
          (system: f nixpkgs.legacyPackages.${system});

      treefmt = eachSystem (pkgs: treefmt-nix.lib.mkWrapper pkgs ./treefmt.nix);
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            mkdocs-numtide.packages.${pkgs.system}.default
            pkgs.nixpkgs-fmt
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
    };
}

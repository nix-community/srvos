{
  description = "srvos dev flake";

  inputs.srvos.url = "path:../";

  inputs.nixpkgs.follows = "srvos/nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { self, nixpkgs, treefmt-nix, srvos, ... }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs
          srvos.lib.supportedSystems
          (system: f nixpkgs.legacyPackages.${system});

      treefmt = eachSystem (pkgs: treefmt-nix.lib.mkWrapper pkgs ./treefmt.nix);
    in
    {
      formatter = eachSystem (pkgs: treefmt.${pkgs.system});

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = [
            pkgs.nixpkgs-fmt
            treefmt.${pkgs.system}
          ];
        };
      });
    };
}

{
  description = "Server-optimized NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = inputs@{ self, nixpkgs, treefmt-nix }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
          ]
          (system: f { inherit self system; pkgs = nixpkgs.legacyPackages.${system}; });
    in
    {
      packages = eachSystem ({ pkgs, ... }: {
        docs = pkgs.callPackage ./docs { };
      });

      # generates future flake outputs: `modules.<kind>.<module-name>`
      modules.nixos = import ./nixos;

      # compat to current schema: `nixosModules` / `darwinModules`
      nixosModules = self.modules.nixos;

      # we use this to test our modules
      nixosConfigurations = import ./nixos/test-configurations.nix inputs;

      checks = eachSystem (import ./checks);

      formatter = eachSystem
        ({ pkgs, ... }:
          let
            treefmt.config = {
              projectRootFile = "flake.nix";
              programs = {
                nixpkgs-fmt.enable = true;
              };
              settings.formatter.deadnix = {
                command = "${pkgs.deadnix}/bin/deadnix";
                options = [ "--edit" "--no-lambda-pattern-names" ];
                includes = [ "*.nix" ];
              };
            };
          in
          treefmt-nix.lib.mkWrapper pkgs treefmt.config
        );
    };
}

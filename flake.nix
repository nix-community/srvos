{
  description = "Server-optimized NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs = inputs@{ self, nixpkgs }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs
          [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
          ]
          (system: f { inherit system; pkgs = nixpkgs.legacyPackages.${system}; });
    in
    {
      packages = eachSystem ({ system, pkgs }: {
        docs = pkgs.callPackage ./docs { };
      });

      # generates future flake outputs: `modules.<kind>.<module-name>`
      modules.nixos = import ./nixos;

      # compat to current schema: `nixosModules` / `darwinModules`
      nixosModules = self.modules.nixos;

      # we use this to test our modules
      nixosConfigurations = import ./nixos/test-configurations.nix inputs;
    };
}

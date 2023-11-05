{
  description = "Server-optimized NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.nixos-23_05.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { nixpkgs, nixos-23_05, self, ... }:
    let
      srvos = self;
      inherit (nixpkgs) lib;
      eachSystem = f:
        lib.genAttrs
          srvos.lib.supportedSystems
          (system: f nixpkgs.legacyPackages.${system});
    in
    {
      lib.supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      checks = eachSystem (pkgs:
        { } // (lib.optionalAttrs (pkgs.system == "x86_64-linux") (import ./dev/checks.nix {
          inherit srvos nixpkgs;
          prefix = "nixos";
          system = pkgs.system;
        })) // (lib.optionalAttrs (pkgs.system == "x86_64-linux") (import ./dev/checks.nix {
          inherit srvos;
          nixpkgs = nixos-23_05;
          prefix = "nixos-23_05";
          system = pkgs.system;
        })));

      # generates future flake outputs: `modules.<kind>.<module-name>`
      modules.nixos = import ./nixos;

      # compat to current schema: `nixosModules` / `darwinModules`
      nixosModules = self.modules.nixos;
    };
}

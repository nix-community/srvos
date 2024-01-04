{
  description = "Server-optimized NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.nixos-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = { nixpkgs, nixos-stable, self, ... }:
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
        (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (import ./dev/checks.nix {
          inherit srvos pkgs lib;
          prefix = "nixos";
          system = pkgs.system;
        })) // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux (import ./dev/checks.nix {
          inherit srvos;
          pkgs = import nixos-stable {
            inherit (pkgs) system;
          };
          inherit (nixos-stable) lib;
          prefix = "nixos-stable";
          system = pkgs.system;
        })));

      # generates future flake outputs: `modules.<kind>.<module-name>`
      modules.nixos = import ./nixos;

      # compat to current schema: `nixosModules` / `darwinModules`
      nixosModules = self.modules.nixos;
    };
}

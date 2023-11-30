{
  description = "Server-optimized NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.nixos-23_05.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { nixpkgs, nixos-23_05, self, ... }:
    let
      srvos = self;
      inherit (nixpkgs) lib;

      permittedInsecurePackages = [
        "nodejs-16.20.0"
        "nodejs-16.20.1"
        "nodejs-16.20.2"
      ];

      eachSystem = f:
        lib.genAttrs
          srvos.lib.supportedSystems
          (system: f (import nixpkgs {
            inherit system;
            config = { inherit permittedInsecurePackages; };
          }));
    in
    {
      lib.supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      checks = eachSystem (pkgs:
        (lib.optionalAttrs (pkgs.system == "x86_64-linux") (import ./dev/checks.nix {
          inherit srvos pkgs lib;
          prefix = "nixos";
          system = pkgs.system;
        })) // (lib.optionalAttrs (pkgs.system == "x86_64-linux") (import ./dev/checks.nix {
          inherit srvos;
          pkgs = import nixos-23_05 {
            inherit (pkgs) system;
            config = { inherit permittedInsecurePackages; };
          };
          inherit (nixos-23_05) lib;
          prefix = "nixos-23_05";
          system = pkgs.system;
        })));

      # generates future flake outputs: `modules.<kind>.<module-name>`
      modules.nixos = import ./nixos;

      # compat to current schema: `nixosModules` / `darwinModules`
      nixosModules = self.modules.nixos;
    };
}

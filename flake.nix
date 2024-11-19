{
  description = "Server-optimized NixOS configuration";

  nixConfig.extra-substituters = [ "https://nix-community.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  outputs =
    publicInputs@{ self, nixpkgs, ... }:
    let
      # Just the NixOS and Darwin modules
      modules = import ./.;

      loadPrivateFlake =
        path:
        let
          flakeHash = nixpkgs.lib.fileContents "${toString path}.narHash";
          flakePath = "path:${toString path}?narHash=${flakeHash}";
        in
        builtins.getFlake (builtins.unsafeDiscardStringContext flakePath);

      privateFlake = loadPrivateFlake ./dev/private;

      inputs = privateFlake.inputs // publicInputs;

      devFlake =
        # builtins.getFlake is not available in flake-compat mode
        if builtins ? getFlake then
          inputs.flake-parts.lib.mkFlake { inherit inputs; } {
            imports = [
              ./dev
            ];
            # Make the modules available for checks
            flake = modules;
          }
        else
          { };
    in
    modules
    //
      # Only load the devFlake if some of those attributes are accessed.
      {
        devShells = devFlake.devShells or { };
        packages = devFlake.packages or { };
        formatter = devFlake.formatter or { };
        checks = devFlake.checks or { };
      };
}

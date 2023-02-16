{
  description = "Server-optimized nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    snow.url = "path:./snow";
  };

  nixConfig = {
    # This is a horrible hack used by snow. We are asking that this gets moved
    # to the top-level ASAP.
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  outputs = inputs@{ snow, ... }: snow.lib.flake inputs;
}

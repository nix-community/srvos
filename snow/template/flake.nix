{
  description = "<your project description>";

  # Put all your dependencies here.
  # We expect both nixpkgs and snow to be there.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    snow.url = "github:numtide/snow";
  };

  nixConfig = {
    # Uncomment this to select which systems you want to support.
    # NOTE: This is a hack and we hope to sway upstream to move it one level
    # up.
    # supportedSystems = [
    #   "x86_64-linux"
    #   "aarch64-linux"
    # ];
  };

  outputs = inputs@{ snow, ... }: snow.lib.flake inputs;
}

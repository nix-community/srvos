{ lib, ... }:
{
  # We define a new prefix that includes *all* the types of modules.
  #
  # Eg: instead of nixosModules, use modules.nixos
  options.flake.modules = lib.mkOption {
    type = lib.types.anything;
  };
}

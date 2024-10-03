{ lib, ... }:
{
  imports = [
    ../../shared/common/flake.nix
    ./nix.nix
    ./openssh.nix
  ];

  # It's the default login shell, and if not enabled, a lot of important configuration is not applied correctly
  # Overhead is minimal, since it's just generated zsh configuration that gets added.
  programs.zsh.enable = lib.mkDefault true;
}

{ lib, ... }:
{
  imports = [
    ../../shared/common/flake.nix
    ./nix.nix
    ./homebrew.nix
    ./openssh.nix
    ./update-diff.nix
    ../../shared/common/well-known-hosts.nix
  ];
}

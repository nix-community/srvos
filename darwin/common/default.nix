{ lib, ... }:
{
  imports = [
    ../../shared/common/flake.nix
    ./nix.nix
    ./openssh.nix
    ./update-diff.nix
    ../../shared/common/well-known-hosts.nix
  ];
}

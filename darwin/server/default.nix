{ lib, pkgs, ... }:
{
  imports = [
    ../common
    ../../shared/server.nix
  ];

  environment.systemPackages = map lib.lowPrio [
    # no config.programs.git.package option on darwin
    pkgs.git
  ];
}

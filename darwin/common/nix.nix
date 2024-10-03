{ lib, config, ... }:
{
  imports = [
    ../../shared/common/nix.nix
  ];

  services.nix-daemon.enable = true;

  # do not use nix.settings.auto-optimise-store, because of https://github.com/NixOS/nix/issues/7273
  nix.optimise.interval = lib.mkDefault [
    {
      Hour = 3;
      Minute = 45;
    }
  ];

  nix.daemonIOLowPriority = lib.mkDefault true;
}

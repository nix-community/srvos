{ lib, config, ... }:
{
  imports = [
    ../../shared/common/nix.nix
  ];

  # do not use nix.settings.auto-optimise-store, because of https://github.com/NixOS/nix/issues/7273
  nix.optimise.automatic = lib.mkDefault true;
  nix.optimise.interval = lib.mkDefault [
    {
      Hour = 3;
      Minute = 45;
    }
  ];

  # If the user is in @admin they are trusted by default.
  nix.settings.trusted-users = [ "@admin" ];
}

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

  # Deprioritize store maintenance I/O so it doesn't starve interactive use.
  # Both services run as root and use LocalStore directly (not via nix-daemon),
  # so throttling must be on the launchd service itself.
  # This mirrors the NixOS side which uses IOSchedulingClass = "idle".
  launchd.daemons.nix-optimise = lib.mkIf config.nix.optimise.automatic {
    serviceConfig = {
      ProcessType = "Background";
      LowPriorityIO = true;
      Nice = 15;
    };
  };

  launchd.daemons.nix-gc = lib.mkIf config.nix.gc.automatic {
    serviceConfig = {
      ProcessType = "Background";
      LowPriorityIO = true;
      Nice = 15;
    };
  };
}

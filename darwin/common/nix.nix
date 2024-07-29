{ lib, config, ... }:
{
  services.nix-daemon.enable = true;

  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = 5;

  # Enable flakes
  nix.settings.experimental-features =
    [
      "nix-command"
      "flakes"
    ]
    ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";

  # The default at 10 is rarely enough.
  nix.settings.log-lines = lib.mkDefault 25;

  # do not use nix.settings.auto-optimise-store, because of https://github.com/NixOS/nix/issues/7273
  nix.optimise.interval = lib.mkDefault [
    {
      Hour = 3;
      Minute = 45;
    }
  ];

  # Avoid disk full issues
  nix.settings.max-free = lib.mkDefault (3000 * 1024 * 1024);
  nix.settings.min-free = lib.mkDefault (512 * 1024 * 1024);

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;

  nix.daemonIOLowPriority = lib.mkDefault true;
}

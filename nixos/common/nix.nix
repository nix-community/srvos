{ lib, ... }:
{
  # Fallback quickly if substituters are not available.
  nix.settings.connect-timeout = 5;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "repl-flake"
    # run builds with network access but without fixed-output checksum
    "impure-derivations"
    # for container in builds support
    "auto-allocate-uids"
    "cgroups"
    # allows to drop references from filesystem images
    "discard-references"
  ];

  # no longer need to pre-allocate build users for everything
  nix.settings.auto-allocate-uids = true;

  # for container in builds support
  nix.settings.system-features = lib.mkDefault [ "uid-range" ];

  # The default at 10 is rarely enough.
  nix.settings.log-lines = lib.mkDefault 25;

  # Avoid disk full issues
  nix.settings.max-free = lib.mkDefault (3000 * 1024 * 1024);
  nix.settings.min-free = lib.mkDefault (512 * 1024 * 1024);

  # TODO: cargo culted.
  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  # Avoid copying unnecessary stuff over SSH
  nix.settings.builders-use-substitutes = true;
}

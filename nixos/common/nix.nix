{ lib, config, ... }:
{
  imports = [
    ../../shared/common/nix.nix
  ];

  # Disable nix channels. Use flakes instead.
  nix.channel.enable = lib.mkDefault false;

  # De-duplicate store paths using hardlinks except in containers
  # where the store is host-managed.
  nix.optimise.automatic = lib.mkDefault (!config.boot.isContainer);

  # TODO: cargo culted.
  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  systemd.services.nix-gc.serviceConfig = {
    CPUSchedulingPolicy = "batch";
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
}

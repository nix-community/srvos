{ lib, config, pkgs, ... }:
let
  cfg = config.roles.nix-remote-builder;
in
{
  _file = ./nix-remote-builder.nix;

  options.roles.nix-remote-builder = {
    schedulerPublicKeys = lib.mkOption {
      description = "SSH public keys of the central build scheduler";
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    # Garbage-collect often
    nix.gc.automatic = true;
    nix.gc.dates = "*:45";
    nix.gc.options = ''--max-freed "$((128 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

    # Randomize GC to avoid thundering herd effects.
    systemd.timers.nix-gc.timerConfig.RandomizedDelaySec = lib.mkForce "1800";

    # Allow more open files for non-root users to run NixOS VM tests.
    security.pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "-"; value = "20480"; }
    ];

    # Give restricted SSH access to the build scheduler
    users.extraUsers.builder.openssh.authorizedKeys.keys = map
      (key:
        ''command="nix-daemon --stdio",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ${key}''
      )
      cfg.schedulerPublicKeys;
    users.users.builder.isNormalUser = true;
    users.users.builder.group = "nogroup";
    nix.settings.trusted-users = ["builder"];
  };
}

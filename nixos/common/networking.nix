{ config, lib, ... }:
{
  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;

  # Keep dmesg/journalctl -k output readable by NOT logging
  # each refused connection on the open internet.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault false;

  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;

  # FIXME: Maybe upstream?
  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services.systemd-networkd.stopIfChanged = false;
  # Services that are only restarted might be not able to resolve when resolved is stopped before
  systemd.services.systemd-resolved.stopIfChanged = false;

  # If networkd in initrd is enabled, just copy the configuration of the normal networkd.
  # Potentially can miss some drivers, but hopefully it would gracefully degrade in those cases
  # See https://github.com/NixOS/nixpkgs/issues/157034#issuecomment-2163512812
  boot.initrd.systemd.network = lib.mkDefault (builtins.removeAttrs config.systemd.network [ "enable" ]);
}

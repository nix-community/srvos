{ lib, ... }:
{
  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;

  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;
  networking.useDHCP = lib.mkDefault false;

  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}

{ config, lib, ... }:
{
  # Avahi is an alternative implementation. If it's enabled, than we don't need the code below.
  config = lib.mkIf (!config.services.avahi.enable) {
    # Allows to find machines on the local network by name, i.e. useful for printer discovery
    systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = lib.mkDefault "yes";
    systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = lib.mkDefault "yes";
    networking.firewall.allowedUDPPorts = [ 5353 ]; # Multicast DNS
  };
}

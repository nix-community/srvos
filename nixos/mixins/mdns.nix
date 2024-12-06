{ config, lib, ... }:
let
  dhcpInterfaces = lib.filterAttrs (i: i.useDHCP == true) config.networking.interfaces;
in
{
  # Avahi is an alternative implementation. If it's enabled, than we don't need the code below.
  config = lib.mkIf (!config.services.avahi.enable) {
    networking.firewall.allowedUDPPorts = [ 5353 ]; # Multicast DNS

    # Allows to find machines on the local network by name, i.e. useful for printer discovery
    systemd.network.networks =
      lib.optionalAttrs (config.networking.useDHCP) {
        "99-ethernet-default-dhcp".networkConfig.MulticastDNS = lib.mkDefault true;
        "99-wireless-client-dhcp".networkConfig.MulticastDNS = lib.mkDefault true;
      }
      // builtins.mapAttrs (_: { networkConfig.MulticastDNS = lib.mkDefault true; }) dhcpInterfaces;
  };
}

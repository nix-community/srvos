{ config, lib, ... }:
let
  mapInterfaceEnabled = i: lib.nameValuePair "40-${i.name}" i.useDHCP;
  mapMDNSConfig = enableMDNS: {
    networkConfig.MulticastDNS = lib.mkDefault enableMDNS;
  };

  configs = {
    "99-ethernet-default-dhcp" = config.networking.useDHCP;
    "99-wireless-client-dhcp" = config.networking.useDHCP;
  } // (lib.mapAttrs' (_: mapInterfaceEnabled) config.networking.interfaces);
in
{
  # Avahi is an alternative implementation. If it's enabled, than we don't need the code below.
  config = lib.mkIf (!config.services.avahi.enable) {
    networking.firewall.allowedUDPPorts = [ 5353 ]; # Multicast DNS

    # Allows to find machines on the local network by name, i.e. useful for printer discovery
    systemd.network.networks = builtins.mapAttrs (_: mapMDNSConfig) configs;
  };
}

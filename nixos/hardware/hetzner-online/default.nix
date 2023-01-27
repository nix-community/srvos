{ config, modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  config = {
    assertions = [
      {
        assertion = config.systemd.network.networks."10-uplink".networkConfig ? Address;
        message = ''
          The machine IPv6 address must be set to
          `systemd.network.networks."10-uplink".networkConfig.Address`
        '';
      }
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      # SATA ssds
      "sd_mod"
      # NVME
      "nvme"
      # FIXME: HDD only servers?
    ];

    networking.useNetworkd = true;
    networking.useDHCP = false;
    # Hetzner servers commonly only have one interface, so its either to just match by that.
    networking.usePredictableInterfaceNames = false;

    systemd.network.networks."10-uplink" = {
      matchConfig.Name = "eth0";
      networkConfig.DHCP = "ipv4";
      # hetzner requires static ipv6 addresses
      networkConfig.Gateway = "fe80::1";
      networkConfig.IPv6AcceptRA = "no";
    };
  };
}

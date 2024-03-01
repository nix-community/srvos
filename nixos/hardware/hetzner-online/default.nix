{ lib, config, modulesPath, ... }:
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

    # To make hetzner kvm console work. It uses VGA rather than serial. Serial leads to nowhere.
    srvos.boot.consoles = lib.mkDefault [ ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      # SATA SSDs/HDDs
      "sd_mod"
      # NVME
      "nvme"
    ];

    networking.useNetworkd = true;
    networking.useDHCP = false;

    systemd.network.networks."10-uplink" = {
      matchConfig.Name = lib.mkDefault "en* eth0";
      networkConfig.DHCP = "ipv4";
      # hetzner requires static ipv6 addresses
      networkConfig.Gateway = "fe80::1";
      networkConfig.IPv6AcceptRA = "no";
    };

    # Network configuration i.e. when we unlock machines with openssh in the initrd
    boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";
  };
}

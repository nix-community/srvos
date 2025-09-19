{
  lib,
  config,
  options,
  modulesPath,
  ...
}:
{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

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
      # SATA SSDs/HDDs
      "sd_mod"
      # NVME
      "nvme"
    ];

    networking.useNetworkd = true;
    networking.useDHCP = false;
    networking.timeServers = [
      "ntp1.hetzner.de"
      "ntp2.hetzner.com"
      "ntp3.hetzner.de"
    ];

    systemd.network.networks."10-uplink" = {
      matchConfig.Name = lib.mkDefault "en* eth0";
      networkConfig.DHCP = "ipv4";
      # hetzner requires static ipv6 addresses
      networkConfig.Gateway = "fe80::1";
      networkConfig.IPv6AcceptRA = "no";
    };

    # Disable the usb0 link because it has an alias beginning with `en...`
    # which will cause it to also be assigned on the default IPv6 route. This
    # will confuse Kubernetes CNIs configured to use DualStack networking.
    systemd.network.networks."01-disable-usb0" = {
      matchConfig = {
        Name = "usb0";
      };
      linkConfig = {
        Unmanaged = true;
      };
    };

    # This option defaults to `networking.useDHCP` which we don't enable
    # however we do use DHCPv4 as part of `10-uplink`, so we want to
    # enable this for legacy stage1 users.
    boot.initrd.network.udhcpc.enable = lib.mkIf (!config.boot.initrd.systemd.enable) true;

    # Network configuration i.e. when we unlock machines with openssh in the initrd
    boot.initrd.systemd.network.networks."10-uplink" = config.systemd.network.networks."10-uplink";

  }
  // (lib.optionalAttrs ((options.srvos.boot or { }) ? consoles) {

    # To make hetzner kvm console work. It uses VGA rather than serial. Serial leads to nowhere.
    srvos.boot.consoles = lib.mkDefault [ ];
  });
}

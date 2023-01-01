{ config, modulesPath, lib, ... }:
{
  imports = [
    ../../mixins/cloud-init.nix
    "${modulesPath}/profiles/qemu-guest.nix"
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

    boot.cleanTmpDir = true;
    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";

    fileSystems."/" = lib.mkDefault { device = "/dev/sda1"; fsType = "ext4"; };

    networking.useNetworkd = true;
    networking.useDHCP = false;

    systemd.network.networks."10-uplink" = {
      matchConfig = {
        Virtualization = true;
        Name = "en* eth*";
      };
      networkConfig.DHCP = "ipv4";
      # hetzner requires static ipv6 addresses
      networkConfig.Gateway = "fe80::1";
      networkConfig.IPv6AcceptRA = "no";
    };
  };
}

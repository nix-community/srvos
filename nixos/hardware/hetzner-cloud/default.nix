{ config, modulesPath, lib, ... }:
{
  imports = [
    ../../mixins/cloud-init.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";
    boot.tmp.cleanOnBoot = true;

    fileSystems."/" = lib.mkDefault { device = "/dev/sda1"; fsType = "ext4"; };

    networking.useNetworkd = true;
    networking.useDHCP = false;
  };
}

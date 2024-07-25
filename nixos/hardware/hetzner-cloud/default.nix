{
  config,
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../mixins/cloud-init.nix
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";

    fileSystems."/" = lib.mkDefault {
      device = "/dev/sda1";
      fsType = "ext4";
    };

    networking.useNetworkd = true;
    networking.useDHCP = false;

    # Needed by the Hetzner Cloud password reset feature.
    services.qemuGuest.enable = lib.mkDefault true;
    # https://discourse.nixos.org/t/qemu-guest-agent-on-hetzner-cloud-doesnt-work/8864/2
    systemd.services.qemu-guest-agent.path = [ pkgs.shadow ];
  };
}

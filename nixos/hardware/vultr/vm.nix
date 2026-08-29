{
  modulesPath,
  lib,
  config,
  ...
}:
{
  imports = [
    ./.
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  services.cloud-init.settings = {
    # cloud-init treats a ZFS dataset as a block filesystem and cannot expand it.
    cloud_init_modules = lib.mkIf config.boot.zfs.enabled (
      lib.mkOverride 900 [
        "migrator"
        "seed_random"
        "bootcmd"
        "write-files"
        "update_hostname"
        "resolv_conf"
        "ca-certs"
        "rsyslog"
        "users-groups"
      ]
    );

    # Vultr VM vendor data attempts to mutate NixOS-managed SSH configuration.
    cloud_config_modules = lib.mkForce [
      "disk_setup"
      "mounts"
      "ssh-import-id"
      "timezone"
      "disable-ec2-metadata"
      "runcmd"
      "ssh"
    ];

    # Vultr VM vendor scripts require /bin/bash and imperatively change system state.
    cloud_final_modules = lib.mkForce [
      "rightscale_userdata"
      "scripts-per-once"
      "scripts-per-boot"
      "scripts-per-instance"
      "scripts-user"
      "ssh-authkey-fingerprints"
      "phone-home"
      "final-message"
      "power-state-change"
    ];
  };

  boot = {
    # Vultr system disks use virtio-blk and may appear too late for ZFS root import.
    initrd.kernelModules = [
      "virtio_pci"
      "virtio_blk"
    ];
    loader.grub.enable = true;
    loader.grub.devices = lib.mkDefault [ "/dev/vda" ];
    # Vultr disks do not expose stable by-id links.
    zfs.devNodes = lib.mkDefault "/dev/disk/by-partuuid";
  };
}

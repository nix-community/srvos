{ lib, config, ... }:
{

  config = {
    services.cloud-init.enable = lib.mkDefault true;
    services.cloud-init.network.enable = lib.mkDefault true;

    # Automatically enable the filesystems that are used
    services.cloud-init.btrfs.enable = lib.mkDefault (lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems));
    services.cloud-init.ext4.enable = lib.mkDefault (lib.any (fs: fs.fsType == "ext4") (lib.attrValues config.fileSystems));

    # Delegate the hostname setting to cloud-init by default
    networking.hostName = lib.mkDefault "";
  };
}

{ lib, config, ... }:
{
  services.cloud-init = {
    enable = lib.mkDefault true;
    network.enable = lib.mkDefault true;

    # Never flush the host's SSH keys. See #148. Since we build the images
    # using NixOS, that kind of issue shouldn't happen to us.
    settings.ssh_deletekeys = lib.mkDefault false;

    ## Automatically enable the filesystems that are used
  }
  // (lib.genAttrs
    ([
      "btrfs"
      "ext4"
      "xfs"
    ])
    (fsName: {
      enable = lib.mkDefault (lib.any (fs: fs.fsType == fsName) (lib.attrValues config.fileSystems));
    })
  );

  networking.useNetworkd = lib.mkDefault true;

  # Delegate the hostname setting to cloud-init by default
  networking.hostName = lib.mkOverride 1337 ""; # lower prio than lib.mkDefault
}

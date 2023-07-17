{ lib, config, ... }:
{
  services.cloud-init = {
    enable = lib.mkDefault true;
    network.enable = lib.mkDefault true;
    ## Automatically enable the filesystems that are used
  } // (lib.genAttrs ([ "btrfs" "ext4" ] ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11") "xfs")
    (fsName: {
      enable = lib.mkDefault (lib.any (fs: fs.fsType == fsName) (lib.attrValues config.fileSystems));
    }));

  # Delegate the hostname setting to cloud-init by default
  networking.hostName = lib.mkDefault "";
}

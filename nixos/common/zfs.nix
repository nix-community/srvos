{ config, lib, ... }:
{
  # You may also find this setting useful to automatically set the latest compatible kernel:
  #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  services.zfs = lib.mkIf (config.boot.zfs.enabled) {
    autoSnapshot.enable = true;
    # defaults to 12, which is a bit much given how much data is written
    autoSnapshot.monthly = lib.mkDefault 1;
    autoScrub.enable = true;
  };
}

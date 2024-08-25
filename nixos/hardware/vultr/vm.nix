{ modulesPath, lib, ... }:
{
  imports = [
    ./.
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkDefault [ "/dev/vda" ];
}

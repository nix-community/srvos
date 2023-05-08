{ modulesPath, ... }:
{
  imports = [
    ./.
    "${modulesPath}/installer/scan/not-detected.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "/dev/vda" ];
  boot.loader.grub.version = 2;
}

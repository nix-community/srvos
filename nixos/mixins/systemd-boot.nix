# Add this mixin to machines that boot with EFI
{ lib, ... }:
{
  # Only enable during install
  #boot.loader.efi.canTouchEfiVariables = true;

  # Use systemd-boot to boot EFI machines
  boot.loader.systemd-boot.configurationLimit = lib.mkOverride 1337 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
}

{
  imports = [
    ./.
  ];

  config = {
    # arm uses EFI, so we need systemd-boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.timeout = 30;
    # since it's a vm, we can do this on every update safely
    boot.loader.efi.canTouchEfiVariables = true;
  };
}

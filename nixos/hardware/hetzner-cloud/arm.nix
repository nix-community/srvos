{
  imports = [ ./. ];

  config = {
    # arm uses EFI, so we need systemd-boot
    boot.loader.systemd-boot.enable = true;
    # since it's a vm, we can do this on every update safely
    boot.loader.efi.canTouchEfiVariables = true;

    # set console because the console defaults to serial and
    # initialize the display early to get a complete log.
    # this is required for typing in LUKS passwords on boot too.
    boot.kernelParams = [ "console=tty" ];
    boot.initrd.kernelModules = [ "virtio_gpu" ];
  };
}

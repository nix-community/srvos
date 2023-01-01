{ lib, config, ... }: {
  imports = [ ./. ];

  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}

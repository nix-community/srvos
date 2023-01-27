{ lib, config, ... }: {
  _file = ./intel.nix;
  imports = [ ./. ];

  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}

{ lib, config, ... }: {
  _file = ./amd.nix;
  imports = [ ./. ];

  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}

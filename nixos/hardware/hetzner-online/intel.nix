{ lib, config, ... }: {

  imports = [ ./. ];

  boot.kernelModules = [ "kvm-intel" ];
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Good thing to do safe the environment and also made EX101 with Intel i9-13900 not crash when running parallel load.
  powerManagement.cpuFreqGovernor = "powersave";
}

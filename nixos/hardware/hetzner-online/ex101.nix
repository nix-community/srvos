{
  imports = [ ./intel.nix ];
  # It looks like Intel i9-13900 draws too much power for a short moment of time when running parallel load.
  # Changing from "performance" to "powersave" governor helps to avoid this.
  powerManagement.cpuFreqGovernor = "powersave";
}

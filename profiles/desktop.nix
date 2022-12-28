{
  imports = [
    ./common.nix
  ];
  # improve desktop responsiveness when updating the system
  nix.daemonIOSchedClass = "idle";
  nix.daemonCPUSchedPolicy = "idle";
}

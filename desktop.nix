{
  imports = [
    ./common
  ];
  # improve desktop responsiveness when updating the system
  nix.daemonCPUSchedPolicy = "idle";
}

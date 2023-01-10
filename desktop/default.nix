{
  imports = [
    ../common
    ./pipewire.nix
  ];
  # improve desktop responsiveness when updating the system
  nix.daemonCPUSchedPolicy = "idle";
}

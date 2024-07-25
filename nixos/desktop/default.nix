{ lib, ... }:
{
  imports = [
    ../common
    ../mixins/mdns.nix
    ./pipewire.nix
  ];

  # The default configuration might put the console on the wrong output and we won't get any boot logs or cryptsetup prompts
  srvos.boot.consoles = lib.mkDefault [ ];

  # improve desktop responsiveness when updating the system
  nix.daemonCPUSchedPolicy = "idle";
}

{ lib, ... }:
{
  imports = [ ../common ];

  nix.daemonIOLowPriority = lib.mkDefault true;
}

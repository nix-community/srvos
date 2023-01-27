{ lib, ... }:
{
  _file = ./cloud-init.nix;
  config = {
    services.cloud-init.enable = true;
    services.cloud-init.network.enable = true;

    # Delegate the hostname setting to cloud-init by default
    networking.hostName = lib.mkDefault "";
  };
}

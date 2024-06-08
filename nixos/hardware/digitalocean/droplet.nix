{ modulesPath, lib, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ../../mixins/cloud-init.nix
  ];
  services.cloud-init.settings.datasource_list = [ "DigitalOcean" ];
  services.cloud-init.settings.datasource.DigitalOcean = { };
  networking.useDHCP = lib.mkForce false;

  # we disable mutable users in srvos
  virtualisation.digitalOcean.setRootPassword = false;
  # we don't allow to read ssh keys from /root/.ssh/authorized_keys
  virtualisation.digitalOcean.setSshKeys = false;
  # This assumes that there is NixOS configuration in /etc/nixos and channels beeing used.
  virtualisation.digitalOcean.rebuildFromUserData = false;
}

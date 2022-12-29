# A default configuration that applies to all servers.
# Common configuration accross *all* the machines
{ config, pkgs, lib, ... }:
{
  imports = [
    ./common/networking.nix
    ./common/nix.nix
    ./common/openssh.nix
    ./common/serial.nix
    ./common/upgrade-diff.nix
    ./common/well-known-hosts.nix
    ./common/zfs.nix
  ];

  # Use systemd during boot as well on systems that do not require networking in early-boot
  boot.initrd.systemd.enable = lib.mkDefault (!config.boot.initrd.network.enable);

  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # Use the better version of nscd
  services.nscd.enableNsncd = true;

  # Allow sudo from the @wheel users
  security.sudo.enable = true;
}

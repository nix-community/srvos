# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{ config, lib, ... }:
{

  imports = [
    ./flake.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./serial.nix
    ./sudo.nix
    ./upgrade-diff.nix
    ./well-known-hosts.nix
    ./zfs.nix
  ];

  system.switch = {
    enable = lib.mkDefault false;
    enableNg = lib.mkDefault true;
  };

  # Use systemd during boot as well except:
  # - systems with raids as this currently require manual configuration: https://github.com/NixOS/nixpkgs/issues/210210
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = lib.mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);

  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
  environment.ldso32 = null;

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = lib.mkDefault true;
}

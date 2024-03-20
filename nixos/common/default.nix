# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{ config, lib, ... }:
{

  imports = [
    ./flake.nix
    ./mdmonitor-fix.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    ./serial.nix
    ./sudo.nix
    ./upgrade-diff.nix
    ./well-known-hosts.nix
    ./zfs.nix
  ];

  # Use systemd during boot as well on systems except:
  # - systems that require networking in early-boot
  # - systems with raids as this currently require manual configuration (https://github.com/NixOS/nixpkgs/issues/210210)
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  boot.initrd.systemd.enable = lib.mkDefault (
    !(if lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11" then
      config.boot.swraid.enable
    else
      config.boot.initrd.services.swraid.enable) &&
    !config.boot.isContainer &&
    !config.boot.growPartition
  );

  # Work around for https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  environment = {
    # This is pulled in by the container profile, but it seems broken and causes
    # unnecessary rebuilds.
    noXlibs = false;
  } // lib.optionalAttrs (lib.versionAtLeast (lib.versions.majorMinor lib.version) "24.05") {
    # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of
    # nixpkgs.
    ldso32 = null;
  };

  # Ensure a clean & sparkling /tmp on fresh boots.
  boot.tmp.cleanOnBoot = lib.mkDefault true;
}

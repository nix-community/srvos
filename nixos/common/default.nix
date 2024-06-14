# A default configuration that applies to all servers.
# Common configuration across *all* the machines
{ options, config, lib, ... }:
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

  system.switch = lib.optionalAttrs (options.system.switch ? enableNg) {
    # can be dropped after 24.05
    enable = lib.mkDefault false;
    enableNg = lib.mkDefault true;
  };

  # Use systemd during boot as well on systems except:
  # - systems with raids as this currently require manual configuration (https://github.com/NixOS/nixpkgs/issues/210210)
  # - for containers we currently rely on the `stage-2` init script that sets up our /etc
  # - For systemd in initrd we have now systemd-repart, but many images still set boot.growPartition
  boot.initrd.systemd.enable = lib.mkDefault (
    !config.boot.swraid.enable &&
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

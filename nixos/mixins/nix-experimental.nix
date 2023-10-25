{ lib, config, ... }:
{
  # Enable flakes
  nix.settings.experimental-features = [
    # for container in builds support
    "auto-allocate-uids"
    "cgroups"
    # run builds with network access but without fixed-output checksum
    "impure-derivations"
  ] ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.18")
    # allows to drop references from filesystem images
    "discard-references";

  # no longer need to pre-allocate build users for everything
  nix.settings.auto-allocate-uids = true;

  # for container in builds support
  nix.settings.system-features = lib.mkDefault [ "uid-range" ];
}

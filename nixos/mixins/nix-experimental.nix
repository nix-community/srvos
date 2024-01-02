{ lib, config, ... }:
{
  # Enable flakes
  nix.settings.experimental-features = [
    # for container in builds support
    "auto-allocate-uids"
    "cgroups"


    # Enable the use of the fetchClosure built-in function in the Nix language.
    "fetch-closure"

    # Allow derivation builders to call Nix, and thus build derivations recursively.
    "recursive-nix"
  ] ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.19")
    # Allow the use of the impure-env setting.
    "configurable-impure-env"
  ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.18")
    # allows to drop references from filesystem images
    "discard-references";

  # no longer need to pre-allocate build users for everything
  nix.settings.auto-allocate-uids = true;

  # for container in builds support
  nix.settings.system-features = lib.mkDefault [ "uid-range" ];
}

{
  lib,
  config,
  pkgs,
  ...
}:
{
  nix.package = lib.mkDefault pkgs.nixVersions.latest;

  # Enable flakes
  nix.settings.experimental-features =
    [
      # for container in builds support
      "auto-allocate-uids"
      "cgroups"

      # Enable the use of the fetchClosure built-in function in the Nix language.
      "fetch-closure"

      # Allow derivation builders to call Nix, and thus build derivations recursively.
      "recursive-nix"

      # Allow the use of the impure-env setting.
      "configurable-impure-env"
    ]
    ++ lib.optionals (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.28") [
      # Allow derivations to be content-addressed in order to prevent rebuilds
      # when changes to the derivation do not result in changes to the
      # derivation's output.
      "ca-derivations"

      # Allow derivations to produce non-fixed outputs by setting the __impure
      # derivation attribute to true. An impure derivation can have differing
      # outputs each time it is built.
      "impure-derivations"
    ]
    ++ lib.optionals (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.29") [
      "blake3-hashes"
    ];

  # no longer need to pre-allocate build users for everything
  nix.settings.auto-allocate-uids = lib.mkDefault true;
  # Needs a patch in Nix to work properly: https://github.com/NixOS/nix/pull/13135
  # nix.settings.use-cgroups = true;

  # for container in builds support
  nix.settings.system-features = [ "uid-range" ];
}

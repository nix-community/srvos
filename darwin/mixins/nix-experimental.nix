{
  pkgs,
  lib,
  config,
  ...
}:
{
  nix.package = lib.mkDefault pkgs.nixVersions.latest;

  # Enable flakes
  nix.settings.experimental-features =
    [
      # Enable the use of the fetchClosure built-in function in the Nix language.
      "fetch-closure"

      # Allow derivation builders to call Nix, and thus build derivations recursively.
      "recursive-nix"

      # Allow derivations to be content-addressed in order to prevent rebuilds
      # when changes to the derivation do not result in changes to the
      # derivation's output.
      "ca-derivations"

      # Allow derivations to produce non-fixed outputs by setting the __impure
      # derivation attribute to true. An impure derivation can have differing
      # outputs each time it is built.
      "impure-derivations"
    ]
    ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.19")
      # Allow the use of the impure-env setting.
      "configurable-impure-env";

  # for container in builds support
  nix.settings.system-features = lib.mkDefault [ "uid-range" ];
}

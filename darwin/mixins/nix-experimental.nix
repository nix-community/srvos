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
    ]
    ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor config.nix.package.version) "2.19")
      # Allow the use of the impure-env setting.
      "configurable-impure-env";
}

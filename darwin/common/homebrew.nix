{
  config,
  lib,
  ...
}:
{
  # Install homebrew if it is not installed
  system.activationScripts.homebrew.text = lib.mkIf config.homebrew.enable (
    lib.mkBefore ''
      if [[ ! -f "${config.homebrew.prefix}/bin/brew" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    ''
  );

  # Don't quarantine apps installed by homebrew with gatekeeper
  homebrew.caskArgs.no_quarantine = lib.mkDefault true;
  # Declarative package management by removing all homebrew packages,
  # not declared in darwin-nix configuration
  homebrew.onActivation.cleanup = lib.mkDefault "uninstall";
}

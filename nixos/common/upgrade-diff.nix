# MIT Jörg Thalheim - https://github.com/Mic92/dotfiles/blob/c6cad4e57016945c4816c8ec6f0a94daaa0c3203/nixos/modules/upgrade-diff.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.srvos.update-diff = {
    enable = lib.mkEnableOption "show package diff when updating nixos" // {
      default = true;
    };
  };
  config = lib.mkIf config.srvos.update-diff.enable {
    system.activationScripts.update-diff = {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };
  };
}

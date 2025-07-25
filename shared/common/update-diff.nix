# MIT Jörg Thalheim - https://github.com/Mic92/dotfiles/blob/c6cad4e57016945c4816c8ec6f0a94daaa0c3203/nixos/modules/upgrade-diff.nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.srvos.update-diff = {
    enable = lib.mkEnableOption "show package diff when updating" // {
      default = true;
    };
    command = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff";
      defaultText = lib.literalExpression ''"''${pkgs.nvd}/bin/nvd --nix-bin-dir=''${config.nix.package}/bin diff"'';
      description = "diff command";
    };
    text = lib.mkOption {
      type = lib.types.str;
      description = "diff script snippet";
    };
  };
  config = {
    srvos.update-diff = {
      text = ''
        if [[ -e /run/current-system && -e "''${incoming-}" ]]; then
          echo "--- diff to current-system"
          ${config.srvos.update-diff.command} /run/current-system "''${incoming-}"
          echo "---"
        fi
      '';
    };
  };
}

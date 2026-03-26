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
      # --force-correctness was added in dix 1.4.2
      default =
        if lib.versionAtLeast (pkgs.dix.version or "0") "1.4.2" then
          "${lib.getExe pkgs.dix} --force-correctness"
        else
          "${lib.getExe pkgs.dix}";
      defaultText = lib.literalExpression ''"''${lib.getExe pkgs.dix} --force-correctness"'';
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

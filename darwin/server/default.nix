{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common
    ../../shared/server.nix
  ];

  # not disabled by the corresponding documentation.* option
  programs.info.enable = lib.mkDefault config.srvos.server.docs.enable;
  programs.man.enable = lib.mkDefault config.srvos.server.docs.enable;

  # remove uninstaller, use 'nix run github:LnL7/nix-darwin#darwin-uninstaller'
  system.tools.darwin-uninstaller.enable = lib.mkDefault false;

  # If the user is in @admin they are trusted by default.
  nix.settings.trusted-users = [ "@admin" ];

  # UTC (GMT) everywhere!
  time.timeZone = lib.mkDefault "GMT";
}

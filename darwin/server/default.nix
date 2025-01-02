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
  system.includeUninstaller = lib.mkDefault false;

  # UTC (GMT) everywhere!
  time.timeZone = lib.mkDefault "GMT";
}

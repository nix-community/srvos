{ lib, pkgs, ... }:
{
  imports = [
    ../common
    ../../shared/server.nix
  ];

  environment.systemPackages = map lib.lowPrio [
    # no config.programs.git.package option on darwin
    pkgs.git
  ];

  # not disabled by the corresponding documentation.* option
  programs.info.enable = lib.mkDefault false;
  programs.man.enable = lib.mkDefault false;

  # remove uninstaller, use 'nix run github:LnL7/nix-darwin#darwin-uninstaller'
  system.includeUninstaller = lib.mkDefault false;

  # UTC (GMT) everywhere!
  time.timeZone = lib.mkDefault "GMT";
}

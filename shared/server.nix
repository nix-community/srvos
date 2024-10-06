{
  config,
  lib,
  pkgs,
  ...
}:
{

  # List packages installed in system profile.
  environment.systemPackages = map lib.lowPrio [
    # no config.programs.git.package option on darwin
    (config.programs.git.package or pkgs.git)
    pkgs.curl
    pkgs.dnsutils
    pkgs.htop
    pkgs.jq
    pkgs.tmux
  ];

  # Notice this also disables --help for some commands such as nixos-rebuild
  documentation.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
}

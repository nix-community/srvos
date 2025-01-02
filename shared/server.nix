{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.srvos.server.docs.enable = lib.mkEnableOption "" // {
    description = ''
      Whether to re-enable documentation disabled by the server profile.
    '';
  };
  config = {
    # List packages installed in system profile.
    environment.systemPackages = map lib.lowPrio [
      # no config.programs.git.package option on darwin
      (config.programs.git.package or pkgs.gitMinimal)
      pkgs.curl
      pkgs.dnsutils
      pkgs.htop
      pkgs.jq
      pkgs.tmux
    ];

    # Notice this also disables --help for some commands such as nixos-rebuild
    documentation.enable = lib.mkDefault config.srvos.server.docs.enable;
    documentation.doc.enable = lib.mkDefault config.srvos.server.docs.enable;
    documentation.info.enable = lib.mkDefault config.srvos.server.docs.enable;
    documentation.man.enable = lib.mkDefault config.srvos.server.docs.enable;
  };
}

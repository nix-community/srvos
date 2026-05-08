{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.roles.nix-remote-builder;
in
{

  options.roles.nix-remote-builder = {
    schedulerPublicKeys = lib.mkOption {
      description = "SSH public keys of the central build scheduler";
      type = lib.types.listOf lib.types.str;
    };
  };

  config = {
    # Give restricted SSH access to the build scheduler
    users.users.nix-remote-builder.openssh.authorizedKeys.keys = map (
      key: ''restrict,command="nix-daemon --stdio" ${key}''
    ) cfg.schedulerPublicKeys;

    nix.settings.trusted-users = [ "nix-remote-builder" ];
  };
}

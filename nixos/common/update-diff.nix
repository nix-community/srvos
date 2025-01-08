{ config, lib, ... }:
{
  imports = [
    ../../shared/common/update-diff.nix
  ];

  config = lib.mkIf config.srvos.update-diff.enable {
    system.preSwitchChecks.update-diff = ''
      incoming="''${1-}"
      ${config.srvos.update-diff.text}
    '';
  };
}

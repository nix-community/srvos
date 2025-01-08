{ config, lib, ... }:
{
  imports = [
    ../../shared/common/update-diff.nix
  ];

  config = lib.mkIf config.srvos.update-diff.enable {
    system.activationScripts.preActivation.text = ''
      incoming="''${systemConfig-}"
      ${config.srvos.update-diff.text}
    '';
  };
}

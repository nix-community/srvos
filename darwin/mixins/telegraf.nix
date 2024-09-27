{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../../shared/mixins/telegraf.nix
  ];

  services.telegraf = {
    extraConfig = {
      inputs = {
        smart.path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
      };
    };
  };
}

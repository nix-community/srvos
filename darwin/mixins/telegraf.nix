{ lib, inputs, pkgs, ... }:
{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        smart.path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
        system = { };
        mem = { };
        swap = { };
        disk.tagdrop.fstype = [ "ramfs" ];
        diskio = { };
        internal = { };
      };
      outputs.prometheus_client = {
        listen = ":9273";
        metric_version = 2;
      };
    };
  };
}

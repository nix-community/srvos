{
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        system = { };
        mem = { };
        swap = { };
        disk.tagdrop = {
          fstype = [
            "tmpfs"
            "ramfs"
            "devtmpfs"
            "devfs"
            "iso9660"
            "overlay"
            "aufs"
            "squashfs"
            "efivarfs"
          ];
          device = [
            "rpc_pipefs"
            "lxcfs"
            "nsfs"
            "borgfs"
          ];
        };
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

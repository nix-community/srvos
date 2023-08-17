{ pkgs, lib, config, ... }:
# To use this module you also need to allow port 9273 either on the internet or on a vpn interface
# i.e. networking.firewall.interfaces."vpn0".allowedTCPPorts = [ 9273 ];
# Example prometheus alert rules:
# - https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix
let
  isVM = lib.any (mod: mod == "xen-blkfront" || mod == "virtio_console") config.boot.initrd.kernelModules;
  # potentially wrong if the nvme is not used at boot...
  hasNvme = lib.any (m: m == "nvme") config.boot.initrd.availableKernelModules;

  ipv6DadCheck = pkgs.writeShellScript "ipv6-dad-check" ''
    ${pkgs.iproute2}/bin/ip --json addr | \
    ${pkgs.jq}/bin/jq -r 'map(.addr_info) | flatten(1) | map(select(.dadfailed == true)) | map(.local) | @text "ipv6_dad_failures count=\(length)i"'
  '';

  zfsChecks = lib.optional
    (lib.any (fs: fs == "zfs") config.boot.supportedFilesystems)
    (pkgs.writeScript "zpool-health" ''
      #!${pkgs.gawk}/bin/awk -f
      BEGIN {
        while ("${pkgs.zfs}/bin/zpool status" | getline) {
          if ($1 ~ /pool:/) { printf "zpool_status,name=%s ", $2 }
          if ($1 ~ /state:/) { printf " state=\"%s\",", $2 }
          if ($1 ~ /errors:/) {
              if (index($2, "No")) printf "errors=0i\n"; else printf "errors=%di\n", $2
          }
        }
      }
    '');

  nfsChecks =
    let
      collectHosts = shares: fs:
        if builtins.elem fs.fsType [ "nfs" "nfs3" "nfs4" ]
        then
          shares
          // (
            let
              # also match ipv6 addresses
              group = builtins.match "\\[?([^\]]+)]?:([^:]+)$" fs.device;
              host = builtins.head group;
              path = builtins.elemAt group 1;
            in
            {
              ${host} = (shares.${host} or [ ]) ++ [ path ];
            }
          )
        else shares;
      nfsHosts = lib.foldl collectHosts { } (builtins.attrValues config.fileSystems);
    in
    lib.mapAttrsToList
      (
        host: args:
          (pkgs.writeScript "nfs-health" ''
            #!${pkgs.gawk}/bin/awk -f
            BEGIN {
              for (i = 2; i < ARGC; i++) {
                  mounts[ARGV[i]] = 1
              }
              while ("${pkgs.nfs-utils}/bin/showmount -e " ARGV[1] | getline) {
                if (NR == 1) { continue }
                if (mounts[$1] == 1) {
                    printf "nfs_export,host=%s,path=%s present=1\n", ARGV[1], $1
                }
                delete mounts[$1]
              }
              for (mount in mounts) {
                  printf "nfs_export,host=%s,path=%s present=0\n", ARGV[1], $1
              }
            }
          '')
          + " ${host} ${builtins.concatStringsSep " " args}"
      )
      nfsHosts;

in
{

  systemd.services.telegraf.path = lib.optional (!isVM && hasNvme) pkgs.nvme-cli;

  services.telegraf = {
    enable = true;
    extraConfig = {
      agent.interval = "60s";
      inputs = {
        prometheus.urls = lib.mkIf config.services.promtail.enable [
          # default promtail port
          "http://localhost:9080/metrics"
        ];
        prometheus.metric_version = 2;
        kernel_vmstat = { };
        nginx.urls = lib.mkIf config.services.nginx.statusPage [
          "http://localhost/nginx_status"
        ];
        smart = lib.mkIf (!isVM) {
          path_smartctl = pkgs.writeShellScript "smartctl" ''
            exec /run/wrappers/bin/sudo ${pkgs.smartmontools}/bin/smartctl "$@"
          '';
        };
        system = { };
        mem = { };
        file =
          [
            {
              data_format = "influx";
              file_tag = "name";
              files = [ "/var/log/telegraf/*" ];
            }
          ]
          ++ lib.optional (lib.any (fs: fs == "ext4") config.boot.supportedFilesystems) {
            name_override = "ext4_errors";
            files = [ "/sys/fs/ext4/*/errors_count" ];
            data_format = "value";
          };
        exec = [
          {
            ## Commands array
            commands =
              [ ipv6DadCheck ]
                ++ zfsChecks
                ++ nfsChecks;
            data_format = "influx";
          }
        ];
        systemd_units = { };
        swap = { };
        disk.tagdrop = {
          fstype = [ "tmpfs" "ramfs" "devtmpfs" "devfs" "iso9660" "overlay" "aufs" "squashfs" ];
          device = [ "rpc_pipefs" "lxcfs" "nsfs" "borgfs" ];
        };
        diskio = { };
        zfs = {
          poolMetrics = true;
        };
      } // lib.optionalAttrs (if lib.versionAtLeast (lib.versions.majorMinor lib.version) "23.11" then config.boot.swraid.enable else config.boot.initrd.services.swraid.enable) {
        mdstat = { };
      };
      outputs.prometheus_client = {
        listen = ":9273";
        metric_version = 2;
      };
    };
  };
  security.sudo.extraRules = lib.mkIf (!isVM) [
    {
      users = [ "telegraf" ];
      commands = [
        {
          command = "${pkgs.smartmontools}/bin/smartctl";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  # avoid logging sudo use
  security.sudo.configFile = ''
    Defaults:telegraf !syslog,!pam_session
  '';
  # create dummy file to avoid telegraf errors
  systemd.tmpfiles.rules = [
    "f /var/log/telegraf/dummy 0444 root root - -"
  ];
}

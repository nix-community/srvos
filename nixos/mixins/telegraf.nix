{
  pkgs,
  lib,
  config,
  ...
}:
# To use this module you also need to allow port 9273 either on the internet or on a vpn interface
# i.e. networking.firewall.interfaces."vpn0".allowedTCPPorts = [ 9273 ];
# Example prometheus alert rules:
# - https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix
let
  isVM = lib.any (
    mod: mod == "xen-blkfront" || mod == "virtio_console"
  ) config.boot.initrd.kernelModules;
  # potentially wrong if the nvme is not used at boot...
  hasNvme = lib.any (m: m == "nvme") config.boot.initrd.availableKernelModules;

  supportsFs = fs: config.boot.supportedFilesystems.${fs} or false;

  ipv6DadCheck = pkgs.writeShellScript "ipv6-dad-check" ''
    ${pkgs.iproute2}/bin/ip --json addr | \
    ${pkgs.jq}/bin/jq -r 'map(.addr_info) | flatten(1) | map(select(.dadfailed == true)) | map(.local) | @text "ipv6_dad_failures count=\(length)i"'
  '';

  zfsChecks = lib.optional (supportsFs "zfs") (
    pkgs.writeScript "zpool-health" ''
      #!${pkgs.gawk}/bin/awk -f
      BEGIN {
        while ("${config.boot.zfs.package}/bin/zpool status" | getline) {
          if ($1 ~ /pool:/) { printf "zpool_status,name=%s ", $2 }
          if ($1 ~ /state:/) { printf " state=\"%s\",", $2 }
          if ($1 ~ /errors:/) {
              if (index($2, "No")) printf "errors=0i\n"; else printf "errors=%di\n", $2
          }
        }
      }
    ''
  );

  nfsChecks =
    let
      collectHosts =
        shares: fs:
        if
          builtins.elem fs.fsType [
            "nfs"
            "nfs3"
            "nfs4"
          ]
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
        else
          shares;
      nfsHosts = lib.foldl collectHosts { } (builtins.attrValues config.fileSystems);
    in
    lib.mapAttrsToList (
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
    ) nfsHosts;

in
{
  imports = [
    ../../shared/mixins/telegraf.nix
  ];

  systemd.services.telegraf.path = lib.optional (!isVM && hasNvme) pkgs.nvme-cli;

  services.telegraf = {
    extraConfig = {
      inputs = {
        prometheus = lib.mkIf config.services.promtail.enable [
          {
            urls = [ "http://localhost:9080/metrics" ]; # default promtail port
            metric_version = 2;
          }
        ];
        kernel_vmstat = { };
        nginx.urls = lib.mkIf config.services.nginx.statusPage [ "http://localhost/nginx_status" ];
        smart = lib.mkIf (!isVM) { path_smartctl = "/run/wrappers/bin/smartctl-telegraf"; };
        file =
          [
            {
              data_format = "influx";
              file_tag = "name";
              files = [ "/var/log/telegraf/*" ];
            }
          ]
          ++ lib.optional (supportsFs "ext4") {
            name_override = "ext4_errors";
            files = [ "/sys/fs/ext4/*/errors_count" ];
            data_format = "value";
          };
        exec = [
          {
            ## Commands array
            commands = [ ipv6DadCheck ] ++ zfsChecks ++ nfsChecks;
            data_format = "influx";
          }
        ];
        systemd_units = { };
        zfs = {
          poolMetrics = true;
        };
      } // lib.optionalAttrs config.boot.swraid.enable { mdstat = { }; };
    };
  };
  security.wrappers.smartctl-telegraf = lib.mkIf (!isVM) {
    owner = "telegraf";
    group = "telegraf";
    capabilities = "cap_sys_admin,cap_dac_override,cap_sys_rawio+ep";
    source = "${pkgs.smartmontools}/bin/smartctl";
  };

  # create dummy file to avoid telegraf errors
  systemd.tmpfiles.rules = [ "f /var/log/telegraf/dummy 0444 root root - -" ];
}

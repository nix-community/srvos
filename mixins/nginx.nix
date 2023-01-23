{ config, lib, ... }: {
  networking.firewall.allowedTCPPorts = [ 443 80 ];

  services.nginx = {
    enable = true;

    recommendedBrotliSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;

    # Nginx sends all the access logs to /var/log/nginx/access.log by default.
    # instead of going to the journal!
    commonHttpConfig = "access_log syslog:server=unix:/dev/log;";

    resolver.addresses =
      let
        isIPv6 = addr: builtins.match ".*:.*:.*" addr != null;
        escapeIPv6 = addr: if isIPv6 addr then "[${addr}]" else addr;
        cloudflare = [ "1.1.1.1" "2606:4700:4700::1111" ];
        resolvers = if config.networking.nameservers == [ ] then cloudflare else config.networking.nameservers;
      in
      map escapeIPv6 resolvers;

    sslDhparam = config.security.dhparams.params.nginx.path;

    # FIXME:
    # nginx: [alert] could not open error log file: open() "/var/log/nginx/error.log" failed (2: No such file or directory)
    # 2022/12/23 02:57:47 [emerg] 7#7: BIO_new_file("/var/lib/dhparams/nginx.pem") failed (SSL: error:80000002:system library::No such file or directory:calling fopen(/var/lib/dhparams/nginx.pem, r) error:10000080:BIO routines::no such file)
    validateConfig = false;
  };

  security.dhparams = {
    enable = true;
    params.nginx = { };
  };
}

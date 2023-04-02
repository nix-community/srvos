{ config, lib, ... }: {

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  services.nginx = {
    enable = true;

    recommendedBrotliSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedZstdSettings = lib.mkDefault true;

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
  };

  security.dhparams = {
    enable = true;
    params.nginx = { };
  };
}

{ lib, config, pkgs, ... }:
let
  cfg = config.roles.github-actions-runner;
in
{
  options.roles.github-actions-runner = {
    url = lib.mkOption {
      description = "URL of the repo or organization to connect to";
      type = lib.types.str;
    };

    tokenFile = lib.mkOption {
      description = "Path to the token";
      type = lib.types.str;
    };

    name = lib.mkOption {
      description = "Prefix name of the runners";
      type = lib.types.str;
      default = "github-runner";
    };

    count = lib.mkOption {
      description = "Number of github actions runner to deploy";
      default = 4;
      type = lib.types.int;
    };

    cachix = {
      cacheName = lib.mkOption {
        description = "Cachix cache name";
      };

      tokenFile = lib.mkOption {
        description = "Path to the token";
        type = lib.types.str;
      };
    };
  };

  config = {
    services.github-runners = builtins.listToAttrs (map
      (n: rec {
        name = "${cfg.name}-${toString n}";
        value = {
          inherit name;
          enable = true;
          url = cfg.url;
          tokenFile = cfg.tokenFile;
          serviceOverrides = {
            DeviceAllow = [ "/dev/kvm" ];
            PrivateDevices = false;
            ExtraGroups = [ "kvm" ];
          };
          extraPackages = [
            pkgs.cachix
            pkgs.nix
            pkgs.openssh
          ];
        };
      })
      (lib.range 1 cfg.count));

    services.cachix-watch-store = {
      enable = true;
      cacheName = cfg.cachix.cacheName;
      cachixTokenFile = cfg.cachix.tokenFile;
      jobs = 4;
    };

  };
}

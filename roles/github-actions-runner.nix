{ lib, config, ... }:
let
  cfg = config.roles.github-actions-runner;
in
{
  imports = [
    ../profiles/default.nix
    ../profiles/cachix-watch-store.nix
    ../profiles/github-actions-runner.nix
  ];

  options.roles.github-actions-runner = {
    count = lib.mkOption {
      
      description = "Number of github actions runner to deploy";
      default = 4;
      types = lib.types.int;
    };

    github-token = "/run/keys/github-token";

    cachix = {
      cacheName = lib.mkOption {
        description = "Cachix cache name";
      };
    };

    cachix-push.enable = true;
    cachix-push.token = "/run/keys/cachix-token";

  };

  config = {

    services.cachix-watch-store = {
      enable = true;
      cacheName = cfg.cachix.cacheName;
      cachixTokenFile = config.age.secrets.cachixConfig.path;
      verbose = true;
      jobs = 4;
    };

  };
}

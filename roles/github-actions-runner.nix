{ lib, config, pkgs, ... }:
let
  cfg = config.roles.github-actions-runner;
in
{
  imports = [
    ../modules/github-runners
  ];

  options.roles.github-actions-runner = {
    url = lib.mkOption {
      description = "URL of the repo or organization to connect to";
      type = lib.types.str;
    };

    tokenFile = lib.mkOption {
      description = "Path to the token";
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    ephemeral = lib.mkOption {
      type = lib.types.bool;
      description = lib.mdDoc ''
        If enabled, causes the following behavior:

        - Passes the `--ephemeral` flag to the runner configuration script
        - De-registers and stops the runner with GitHub after it has processed one job
        - On stop, systemd wipes the runtime directory (this always happens, even without using the ephemeral option)
        - Restarts the service after its successful exit
        - On start, wipes the state directory and configures a new runner

        You should only enable this option if `tokenFile` points to a file which contains a
        personal access token (PAT). If you're using the option with a registration token, restarting the
        service will fail as soon as the registration token expired.
      '';
      default = true;
    };


    githubApp = lib.mkOption {
      default = null;
      description = lib.mdDoc ''
        Authenticate runners using GitHub App
      '';
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          id = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "GitHub App ID";
          };
          login = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "GitHub login used to register the application";
          };
          privateKeyFile = lib.mkOption {
            type = lib.types.path;
            description = lib.mdDoc ''
              The full path to a file containing the GitHub App private key.
            '';
          };
        };
      });
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
    services.srvos-github-runners = builtins.listToAttrs (map
      (n: rec {
        name = "${cfg.name}-${toString n}";
        value = {
          inherit name;
          enable = true;
          url = cfg.url;
          tokenFile = cfg.tokenFile;
          githubApp = cfg.githubApp;
          ephemeral = cfg.ephemeral;
          serviceOverrides = {
            DeviceAllow = [ "/dev/kvm" ];
            PrivateDevices = false;
            ExtraGroups = [ "kvm" ];
          };
          extraPackages = [
            pkgs.cachix
            pkgs.nix
            pkgs.openssh
            pkgs.glibc.bin
          ];
          extraLabels = [ "nix" ];
        };
      })
      (lib.range 1 cfg.count));

    # Required to run unmodified binaries fetched via dotnet in a dev environment.
    programs.nix-ld.enable = true;

    # Automatically sync all the locally built artifacts to cachix.
    services.cachix-watch-store = {
      enable = true;
      cacheName = cfg.cachix.cacheName;
      cachixTokenFile = cfg.cachix.tokenFile;
      jobs = 4;
    };

  };
}

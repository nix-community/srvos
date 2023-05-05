{ lib, config, pkgs, ... }:
let
  cfg = config.roles.github-actions-runner;
  queued-build-hook = builtins.fetchTarball {
    url = "https://github.com/nix-community/queued-build-hook/archive/dcbc8cdf915370abb789b108088d42e241008c2f.tar.gz";
    sha256 = "0y02741kpk57h54jnm8y6qa60fr0wklajy13sk4r02hq7m4vz6rr";
  };
in
{

  imports = [
    ../modules/github-runners
    "${queued-build-hook}/module.nix"
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

    extraReadWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc ''
        The GitHub Runner service is configured to makes the entire system read-only by default.
        This option can be used to allow specific paths to remain writable for the service.

        Warning: As different unit might get the same UID/GID assigned later on, the files created in those paths are 
        eventually accessible to all github runners. 
        Therefore, this option should not be used if different GitHub Action pipelines should not be able to access state between each other for security reasons
      '';
      default = [ ];
    };

    cachix = {
      cacheName = lib.mkOption {
        description = "Cachix cache name";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      tokenFile = lib.mkOption {
        description = "Path to the token";
        type = lib.types.str;
      };
    };

    binary-cache = {
      script = lib.mkOption {
        description = lib.mdDoc "Script used by asynchronous process to upload Nix packages to the binary cache, without requiring the use of Cachix.";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      enqueueScript = lib.mkOption {
        description = lib.mdDoc ''
          Script content responsible for enqueuing newly-built packages and passing them to the daemon.

          Although the default configuration should suffice, there may be situations that require customized handling of specific packages.
          For example, it may be necessary to process certain packages synchronously using the 'queued-build-hook wait' command, or to ignore certain packages entirely.
        '';
        type = lib.types.str;
        default = "";
      };
      credentials = lib.mkOption {
        description = lib.mdDoc ''
          Credentials to load by startup. Keys that are UPPER_SNAKE will be loaded as env vars. Values are absolute paths to the credentials.
        '';
        type = lib.types.attrsOf lib.types.str;
        default = { };

        example = {
          AWS_SHARED_CREDENTIALS_FILE = "/run/keys/aws-credentials";
          binary-cache-key = "/run/keys/binary-cache-key";
        };
      };
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = lib.mdDoc ''
        Extra packages to add to `PATH` of the service to make them available to workflows.
      '';
      default = [ ];
    };

    extraLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = lib.mdDoc ''
        Extra labels to add to the runners to be able to target them.
      '';
      default = [ "nix" ];
    };


  };

  config = {
    users.groups.github-runner = lib.mkIf (cfg.extraReadWritePaths != [ ]) { };
    services.srvos-github-runners = builtins.listToAttrs (map
      (n: rec {
        name = "${cfg.name}-${toString n}";
        value = {
          inherit name;
          user = name;
          enable = true;
          url = cfg.url;
          tokenFile = cfg.tokenFile;
          githubApp = cfg.githubApp;
          ephemeral = cfg.ephemeral;
          serviceOverrides = {
            DeviceAllow = [ "/dev/kvm" ];
            PrivateDevices = false;
          } // (lib.optionalAttrs (cfg.extraReadWritePaths != [ ]) {
            ReadWritePaths = cfg.extraReadWritePaths;
            Group = [ "github-runner" ];
          });
          extraPackages = [
            pkgs.cachix
            pkgs.glibc.bin
            pkgs.jq
            config.nix.package
            pkgs.nix-eval-jobs
            pkgs.openssh
          ] ++ cfg.extraPackages;
          extraLabels = cfg.extraLabels;
        };
      })
      (lib.range 1 cfg.count));

    # Required to run unmodified binaries fetched via dotnet in a dev environment.
    programs.nix-ld.enable = true;

    # Automatically sync all the locally built artifacts to cachix.
    services.cachix-watch-store = lib.mkIf (cfg.cachix.cacheName != null) {
      enable = true;
      cacheName = cfg.cachix.cacheName;
      cachixTokenFile = cfg.cachix.tokenFile;
      jobs = 4;
    };

    queued-build-hook = lib.mkIf (cfg.binary-cache.script != null)
      ({
        enable = true;
        postBuildScriptContent = cfg.binary-cache.script;
        credentials = cfg.binary-cache.credentials;
      } // (lib.optionalAttrs (cfg.binary-cache.enqueueScript != "") {
        enqueueScriptContent = cfg.binary-cache.enqueueScript;
      }));
  };
}

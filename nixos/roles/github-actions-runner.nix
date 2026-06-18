{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.roles.github-actions-runner;
  queued-build-hook = builtins.fetchTarball {
    url = "https://github.com/nix-community/queued-build-hook/archive/cd0fcdcef049b3351cfa1c5e051e5527ebd1ae18.tar.gz";
    sha256 = "000dmcdp44bndr9vd782js8s4s9j61mp1wv7qpi8ycvvc2036q5y";
  };
in
{

  imports = [
    ../modules/github-runners
    "${queued-build-hook}/module.nix"
    (lib.mkRemovedOptionModule
      [
        "roles"
        "github-actions-runner"
        "url"
      ]
      "Configure `roles.github-actions-runner.orgs.<name>.url` instead. Each org is now declared under `orgs`."
    )
    (lib.mkRemovedOptionModule
      [
        "roles"
        "github-actions-runner"
        "count"
      ]
      "Configure `roles.github-actions-runner.orgs.<name>.count` instead. Each org is now declared under `orgs`."
    )
  ];

  options.roles.github-actions-runner = {
    orgs = lib.mkOption {
      default = { };
      description = ''
        Organizations (or repositories) the runners should serve.

        Each entry generates its own set of runners. When a `githubApp` is
        configured globally, the same GitHub App is used for every org and only
        the `login` (defaulting to the attribute name) changes. Install the App
        on each org and list them here.

        The attribute name is used both as the runner name infix
        (`<name>-<org>-<n>`) and, by default, as the org `login` and `url`.
      '';
      example = lib.literalExpression ''
        {
          org-a = { };
          org-b = {
            count = 2;
            extraLabels = [ "org-b" ];
          };
        }
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              url = lib.mkOption {
                description = "URL of the repo or organization to connect to. Defaults to the GitHub URL derived from the attribute name.";
                type = lib.types.str;
                default = "https://github.com/${name}";
                defaultText = lib.literalExpression "https://github.com/\${name}";
              };

              login = lib.mkOption {
                description = "GitHub login (org/user) where the shared GitHub App is installed. Defaults to the attribute name.";
                type = lib.types.str;
                default = name;
                defaultText = lib.literalExpression "\${name}";
              };

              count = lib.mkOption {
                description = "Number of GitHub Actions runners to deploy for this org.";
                type = lib.types.int;
                default = 4;
              };

              extraLabels = lib.mkOption {
                description = "Extra labels added (on top of the global `extraLabels`) only to this org's runners.";
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };

              tokenFile = lib.mkOption {
                description = ''
                  Path to a token file for this org. Used only when no global
                  `githubApp` is configured. Defaults to the global `tokenFile`.
                '';
                type = lib.types.nullOr lib.types.path;
                default = cfg.tokenFile;
                defaultText = lib.literalExpression "config.roles.github-actions-runner.tokenFile";
              };
            };
          }
        )
      );
    };

    tokenFile = lib.mkOption {
      description = "Path to the token. Used as the default for `orgs.<name>.tokenFile` when no `githubApp` is configured.";
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    ephemeral = lib.mkOption {
      type = lib.types.bool;
      description = ''
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
      description = ''
        Authenticate runners using GitHub App
      '';
      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.str;
              description = "GitHub App ID";
            };
            login = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              visible = false;
              description = "Removed. Configure `roles.github-actions-runner.orgs.<name>.login` instead.";
            };
            privateKeyFile = lib.mkOption {
              type = lib.types.path;
              description = ''
                The full path to a file containing the GitHub App private key.
              '';
            };
          };
        }
      );
    };

    name = lib.mkOption {
      description = "Prefix name of the runners";
      type = lib.types.str;
      default = "github-runner";
    };

    extraReadWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
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
        description = "Script used by asynchronous process to upload Nix packages to the binary cache, without requiring the use of Cachix.";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      enqueueScript = lib.mkOption {
        description = ''
          Script content responsible for enqueuing newly-built packages and passing them to the daemon.

          Although the default configuration should suffice, there may be situations that require customized handling of specific packages.
          For example, it may be necessary to process certain packages synchronously using the 'queued-build-hook wait' command, or to ignore certain packages entirely.
        '';
        type = lib.types.str;
        default = "";
      };
      credentials = lib.mkOption {
        description = ''
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
      description = ''
        Extra packages to add to `PATH` of the service to make them available to workflows.
      '';
      default = [ ];
    };

    extraLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Extra labels to add to the runners to be able to target them.
      '';
      default = [ "nix" ];
    };

    nodeRuntimes = lib.mkOption {
      type =
        with lib.types;
        nonEmptyListOf (enum [
          "node20"
          "node24"
        ]);
      default = [ "node24" ];
      description = ''
        List of Node.js runtimes the runner should support.
      '';
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.githubApp == null || cfg.githubApp.login == null;
          message = "`roles.github-actions-runner.githubApp.login` has been removed. The login is now derived per org from `roles.github-actions-runner.orgs.<name>.login` (defaulting to the attribute name).";
        }
      ];
    }
    (lib.mkIf (cfg.orgs != { }) {
      users.groups.github-runner = lib.mkIf (cfg.extraReadWritePaths != [ ]) { };
      services.srvos-github-runners = builtins.listToAttrs (
        lib.flatten (
          lib.mapAttrsToList (
            orgName: org:
            map (n: rec {
              name = "${cfg.name}-${orgName}-${toString n}";
              value = {
                inherit name;
                user = name;
                enable = true;
                url = org.url;
                tokenFile = if cfg.githubApp != null then null else org.tokenFile;
                githubApp =
                  if cfg.githubApp != null then
                    {
                      inherit (cfg.githubApp) id privateKeyFile;
                      login = org.login;
                    }
                  else
                    null;
                ephemeral = cfg.ephemeral;
                nodeRuntimes = cfg.nodeRuntimes;
                serviceOverrides = {
                  DeviceAllow = [ "/dev/kvm" ];
                  PrivateDevices = false;
                }
                // (lib.optionalAttrs (cfg.extraReadWritePaths != [ ]) {
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
                ]
                ++ cfg.extraPackages;
                extraLabels = cfg.extraLabels ++ org.extraLabels;
              };
            }) (lib.range 1 org.count)
          ) cfg.orgs
        )
      );

      # Required to run unmodified binaries fetched via dotnet in a dev environment.
      programs.nix-ld.enable = true;

      # Automatically sync all the locally built artifacts to cachix.
      services.cachix-watch-store = lib.mkIf (cfg.cachix.cacheName != null) {
        enable = true;
        cacheName = cfg.cachix.cacheName;
        cachixTokenFile = cfg.cachix.tokenFile;
        jobs = 4;
      };

      queued-build-hook = lib.mkIf (cfg.binary-cache.script != null) (
        {
          enable = true;
          postBuildScriptContent = cfg.binary-cache.script;
          credentials = cfg.binary-cache.credentials;
        }
        // (lib.optionalAttrs (cfg.binary-cache.enqueueScript != "") {
          enqueueScriptContent = cfg.binary-cache.enqueueScript;
        })
      );
    })
  ];
}

# We use the nixosConfigurations to test all the modules below.
#
# This is not optimal, but it gets the job done
{ srvos, nixpkgs, system }:
let
  inherit (nixpkgs) lib;
  inherit (lib) nixosSystem;

  # some example configuration to make it eval
  dummy = { config, ... }: {
    networking.hostName = "example-common";
    system.stateVersion = config.system.nixos.version;
    users.users.root.initialPassword = "fnord23";
    boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
    fileSystems."/".device = lib.mkDefault "/dev/sda";
  };
in
{
  # General
  example-common = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.common
    ];
  };
  example-server = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.server
    ];
  };
  example-desktop = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.desktop
    ];
  };

  # Hardware
  example-hardware-amazon = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.hardware-amazon
    ];
  };
  example-hardware-hetzner-cloud = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.hardware-hetzner-cloud
      {
        systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef";
      }
    ];
  };
  example-hardware-vultr-bare-metal = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.hardware-vultr-bare-metal
    ];
  };
  example-hardware-vultr-vm = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.hardware-vultr-vm
    ];
  };

  # Mixins
  example-mixins-cloud-init = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-cloud-init
    ];
  };
  example-mixins-systemd-boot = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-systemd-boot
    ];
  };
  example-mixins-telegraf = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-telegraf
    ];
  };
  example-mixins-terminfo = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-terminfo
    ];
  };
  example-mixins-trusted-nix-caches = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-trusted-nix-caches
    ];
  };
  example-mixins-nginx = nixosSystem {
    inherit system;
    modules = [
      dummy
      srvos.nixosModules.mixins-nginx
    ];
  };

  # Roles
  example-roles-github-actions-runner = nixosSystem {
    inherit system;
    modules = [
      srvos.nixosModules.roles-github-actions-runner
      dummy
      {
        roles.github-actions-runner.cachix.cacheName = "cache-name";
        roles.github-actions-runner.cachix.tokenFile = "/run/cachix-token-file";
        roles.github-actions-runner.tokenFile = "/run/gha-token-file";
        roles.github-actions-runner.url = "https://fixup";
      }
    ];
  };
  example-roles-github-actions-runner-github-app = nixosSystem {
    inherit system;
    modules = [
      srvos.nixosModules.roles-github-actions-runner
      dummy
      {
        roles.github-actions-runner.cachix.cacheName = "cache-name";
        roles.github-actions-runner.cachix.tokenFile = "/run/cachix-token-file";
        roles.github-actions-runner.githubApp = {
          id = "1234";
          login = "foo";
          privateKeyFile = "/run/gha-token-file";
        };
        roles.github-actions-runner.url = "https://fixup";
      }
    ];
  };
  example-roles-github-actions-runner-github-app-queued-build-hook = nixosSystem {
    inherit system;
    modules = [
      srvos.nixosModules.roles-github-actions-runner
      dummy
      {
        roles.github-actions-runner = {
          githubApp = {
            id = "1234";
            login = "foo";
            privateKeyFile = "/run/gha-token-file";
          };
          url = "https://fixup";
          binary-cache.script = ''
            exec nix copy --experimental-features nix-command --to "file:///var/nix-cache" $OUT_PATHS
          '';
        };
      }
    ];
  };

  example-roles-nix-remote-builder = nixosSystem {
    inherit system;
    modules = [
      srvos.nixosModules.roles-nix-remote-builder
      dummy
      {
        roles.nix-remote-builder.schedulerPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz zimbatm@no1"
        ];
      }
    ];
  };
}

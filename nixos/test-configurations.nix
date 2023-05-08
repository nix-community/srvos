# We use the nixosConfigurations to test all the modules below.
#
# This is not optimal, but it gets the job done
{ self, nixpkgs }:
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
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.common
    ];
  };
  example-server = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.server
    ];
  };
  example-desktop = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.desktop
    ];
  };

  # Hardware
  example-hardware-amazon = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.hardware-amazon
    ];
  };
  example-hardware-hetzner-cloud = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.hardware-hetzner-cloud
      {
        systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef";
      }
    ];
  };
  example-hardware-vultr-bare-metal = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.hardware-vultr-bare-metal
    ];
  };
  example-hardware-vultr-vm = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.hardware-vultr-vm
    ];
  };

  # Mixins
  example-mixins-cloud-init = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-cloud-init
    ];
  };
  example-mixins-systemd-boot = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-systemd-boot
    ];
  };
  example-mixins-telegraf = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-telegraf
    ];
  };
  example-mixins-terminfo = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-terminfo
    ];
  };
  example-mixins-trusted-nix-caches = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-trusted-nix-caches
    ];
  };
  example-mixins-nginx = nixosSystem {
    system = "x86_64-linux";
    modules = [
      dummy
      self.nixosModules.mixins-nginx
    ];
  };

  # Roles
  example-roles-github-actions-runner = nixosSystem {
    system = "x86_64-linux";
    modules = [
      self.nixosModules.roles-github-actions-runner
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
    system = "x86_64-linux";
    modules = [
      self.nixosModules.roles-github-actions-runner
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
    system = "x86_64-linux";
    modules = [
      self.nixosModules.roles-github-actions-runner
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
    system = "x86_64-linux";
    modules = [
      self.nixosModules.roles-nix-remote-builder
      dummy
      {
        roles.nix-remote-builder.schedulerPublicKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuiDoBOxgyer8vGcfAIbE6TC4n4jo8lhG9l01iJ0bZz zimbatm@no1"
        ];
      }
    ];
  };
}

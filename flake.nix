{
  description = "Server-optimized nixos configuration";

  inputs = {
    # FIXME: how do we handle multiple releases in future? multiple branches?
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules = import ./.;

    nixosConfigurations =
      let
        fake-hardware = {
          boot.loader.grub.devices = [ "/dev/sda" ];
          fileSystems."/" = {
            device = "/dev/sda";
          };
        };
        # some example configuration to make it eval
        dummy = { config, ... }: {
          networking.hostName = "example-common";
          system.stateVersion = config.system.nixos.version;
          users.users.root.initialPassword = "fnord23";
        };
      in
      {
        # General
        example-common = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.common
          ];
        };
        example-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.server
          ];
        };
        example-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.desktop
          ];
        };

        # Hardware
        example-hardware-amazon = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            self.nixosModules.hardware-amazon
          ];
        };
        example-hardware-hetzner-cloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            self.nixosModules.hardware-hetzner-cloud
            {
              systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef";
            }
          ];
        };

        # Mixins
        example-mixins-cloud-init = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.mixins-cloud-init
          ];
        };
        example-mixins-systemd-boot = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.mixins-systemd-boot
          ];
        };
        example-mixins-telegraf = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.mixins-telegraf
          ];
        };
        example-mixins-terminfo = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.mixins-terminfo
          ];
        };
        example-mixins-nginx = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            dummy
            fake-hardware
            self.nixosModules.mixins-nginx
          ];
        };

        # Roles
        example-roles-github-actions-runner = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.roles-github-actions-runner
            dummy
            fake-hardware
            {
              roles.github-actions-runner.cachix.cacheName = "cache-name";
              roles.github-actions-runner.cachix.tokenFile = "/run/cachix-token-file";
              roles.github-actions-runner.tokenFile = "/run/gha-token-file";
              roles.github-actions-runner.url = "https://fixup";
            }
          ];
        };
        example-roles-github-actions-runner-github-app = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.roles-github-actions-runner
            dummy
            fake-hardware
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
      };
  };
}

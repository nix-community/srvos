{ lib, self, config, inputs, ... }:
{
  # generates future flake outputs: `modules.<kind>.<module-name>`
  config.flake.modules.nixos = import ./.;

  # compat to current schema: `nixosModules` / `darwinModules`
  config.flake.nixosModules = config.flake.modules.nixos or { };

  # the test NixOS configurations
  config.flake.nixosConfigurations =
    let
      nixosSystem = args:
        # TODO: flake-parts does not expose lib.nixosSystems.
        #   Fix this upstream at flake-parts or nixpkgs.
        #   (Why are there even two different libs ?)
        import (inputs.nixpkgs + /nixos/lib/eval-config.nix) (
          args // {
            modules = args.modules ++ [{
              system.nixos.versionSuffix =
                ".${lib.substring 0 8 (self.lastModifiedDate or self.lastModified or "19700101")}.${self.shortRev or "dirty"}";
              system.nixos.revision = lib.mkIf (self ? rev) self.rev;
            }];
          } // lib.optionalAttrs (! args?system) {
            # Allow system to be set modularly in nixpkgs.system.
            # We set it to null, to remove the "legacy" entrypoint's
            # non-hermetic default.
            system = null;
          }
        );
      # some example configuration to make it eval
      dummy = { config, ... }: {
        networking.hostName = "example-common";
        system.stateVersion = config.system.nixos.version;
        users.users.root.initialPassword = "fnord23";
        boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
        fileSystems."/".device = lib.mkDefault  "/dev/sda";
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
    };
}

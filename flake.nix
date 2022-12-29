{
  description = "Server-optimized nixos configuration";

  inputs = {
    # FIXME: how do we handle multiple releases in future? multiple branches?
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules = {
      # Profiles
      common = import ./profiles/common.nix;
      server = import ./profiles/server.nix;
      desktop = import ./profiles/desktop.nix;

      efi = import ./profiles/efi.nix;
      telegraf = import ./profiles/telegraf.nix;
      nginx = import ./profiles/nginx.nix;

      # Roles
      github-actions-runner = import ./roles/github-actions-runner.nix;
    };

    nixosConfigurations =
      let
        # some example configuration to make it eval
        dummy = { config, ... }: {
          networking.hostName = "example-common";
          boot.loader.grub.devices = [ "/dev/sda" ];
          fileSystems."/" = {
            device = "/dev/sda";
          };
          system.stateVersion = config.system.nixos.version;
          users.users.root.initialPassword = "fnord23";
        };
      in
      {
        example-common = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.common
            dummy
          ];
        };
        example-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.server
            dummy
          ];
        };
        example-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.desktop
            dummy
          ];
        };

        example-github-runner = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.github-actions-runner
            dummy
            {
              roles.github-actions-runner.cachix.cacheName = "cache-name";
              roles.github-actions-runner.cachix.tokenFile = "/run/cachix-token-file";
              roles.github-actions-runner.tokenFile = "/run/gha-token-file";
              roles.github-actions-runner.url = "https://fixup";
            }
          ];
        };

        example-telegraf = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.telegraf
            dummy
          ];
        };

        example-nginx = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.nixosModules.nginx
            dummy
          ];
        };
      };
  };
}

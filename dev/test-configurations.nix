# We use the nixosConfigurations to test all the modules below.
#
# This is not optimal, but it gets the job done
{ self, pkgs }:
let
  lib = pkgs.lib;
  system = pkgs.stdenv.hostPlatform.system;

  nixosSystem =
    args: import "${toString pkgs.path}/nixos/lib/eval-config.nix" ({ inherit lib system; } // args);

  # some example configuration to make it eval
  dummy =
    { config, ... }:
    {
      networking.hostName = "example-common";
      system.stateVersion = config.system.nixos.release;
      users.users.root.initialPassword = "fnord23";
      boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
      fileSystems."/".device = lib.mkDefault "/dev/sda";
      fileSystems."/".fsType = lib.mkDefault "auto";

      systemd.enableStrictShellChecks = true;

      documentation.nixos.includeAllModules = true;

      # Don't reinstantiate nixpkgs for every nixos eval.
      # Also important to have nixpkgs config which allows for some required insecure packages
      nixpkgs = {
        inherit pkgs;
      };
    };
in
{
  # General
  example-common = nixosSystem {
    modules = [
      dummy
      self.nixosModules.common
    ];
  };
  example-server = nixosSystem {
    modules = [
      dummy
      self.nixosModules.server
    ];
  };
  example-server-docs = nixosSystem {
    modules = [
      dummy
      self.nixosModules.server
      {
        # docs disabled by default for server
        srvos.server.docs.enable = true;
      }
    ];
  };
  example-desktop = nixosSystem {
    modules = [
      dummy
      self.nixosModules.desktop
    ];
  };

  # Hardware
  example-hardware-amazon = nixosSystem {
    modules = [
      dummy
      self.nixosModules.hardware-amazon
      { systemd.services.fetch-ec2-metadata.enableStrictShellChecks = false; }
    ];
  };
  example-hardware-digitalocean-droplet = nixosSystem {
    modules = [
      dummy
      self.nixosModules.hardware-digitalocean-droplet
      {
        systemd.services.digitalocean-entropy-seed.enableStrictShellChecks = false;
        systemd.services.digitalocean-metadata.enableStrictShellChecks = false;
      }
    ];
  };
  example-hardware-hetzner-cloud = nixosSystem {
    modules = [
      dummy
      self.nixosModules.hardware-hetzner-cloud
      { systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef"; }
    ];
  };
  example-hardware-hetzner-cloud-arm =
    if (system == "aarch64-linux") then
      nixosSystem {
        modules = [
          dummy
          self.nixosModules.hardware-hetzner-cloud-arm
          { systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef"; }
        ];
      }
    else
      null;
  example-hardware-hetzner-online-amd =
    if (system == "x86_64-linux") then
      nixosSystem {
        modules = [
          dummy
          self.nixosModules.hardware-hetzner-online-amd
          { systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef"; }
        ];
      }
    else
      null;
  example-hardware-hetzner-online-intel =
    if (system == "x86_64-linux") then
      nixosSystem {
        modules = [
          dummy
          self.nixosModules.hardware-hetzner-online-intel
          { systemd.network.networks."10-uplink".networkConfig.Address = "::cafe:babe:feed:face:dead:beef"; }
        ];
      }
    else
      null;
  example-hardware-vultr-bare-metal = nixosSystem {
    modules = [
      dummy
      self.nixosModules.hardware-vultr-bare-metal
    ];
  };
  example-hardware-vultr-vm = nixosSystem {
    modules = [
      dummy
      self.nixosModules.hardware-vultr-vm
    ];
  };

  # Mixins
  example-mixins-cloud-init = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-cloud-init
    ];
  };
  example-mixins-systemd-boot = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-systemd-boot
    ];
  };
  example-mixins-telegraf = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-telegraf
    ];
  };
  example-mixins-terminfo = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-terminfo
    ];
  };
  example-mixins-trusted-nix-caches = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-trusted-nix-caches
    ];
  };
  example-mixins-nginx = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-nginx
    ];
  };
  examples-mixin-latest-zfs-kernel = nixosSystem {
    modules = [
      dummy
      self.nixosModules.mixins-latest-zfs-kernel
    ];
  };

  # Roles
  example-roles-nix-remote-builder = nixosSystem {
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

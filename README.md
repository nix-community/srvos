# srvos

STATUS: **experimental**

Opinionated and sharable set of NixOS configurations.

As we learn more about NixOS in various deployments, we end up re-writing the same modules and configs. This is a way for us to speed up and share our setups.

## Usage

Add `srvos` to your flake.nix and include it in your nixos configuration. For
example to deploy a GitHub Action runner on Hetzner:

```nix
{
  inputs = {
    srvos.url = "github:numtide/srvos";
  };
  outputs = { srvos, nixpkgs, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        srvos.nixosModules.common
        srvos.nixosModules.hardware-hetzner-amd
        srvos.nixosModules.roles-github-actions-runner
      ];
    };
  };
}
```

## Modules

All modules are defined in this [file](default.nix)

### General

Used to define the type of machine.

- `server`:
  - Use this for headless systems that are remotely managed via ssh
  - Includes everything from common
  - Disables desktop features like sound
  - Defaults to UTC
  - Enables ssh
  - Configures watchdog for reboot
  - Sets up sudo without password
  - ...
- `desktop`:
  - Mostly based on common but also includes some optimization for useful for interactive usage
- `common`:
  - Use if you are unsure if your nixos module will be used on server or desktop
  - Better nix-daemon defaults
  - Better serial console support
  - Colored package diffs on nixos-rebuild
  - Use systemd in initrd by default and networkd as a backend for the
    Networking module
  - Do not block on networkd/networkmanager's online target
  - Better zfs defaults
  - Add well-known ssh git ssh keys to the git configuration

### Hardware

NixOS hardware configurations that we know about.

- `hardware-amazon`: Amazon AWS virtual machines
- `hardware-hetzner-cloud`: Hardware and network defaults for Hetzner virtual machine
- `hardware-hetzner-amd`: Hardware and network defaults for Hetzner bare-metal servers for AMD and Intel cpus.
- `hardware-hetzner-intel`: "

### Mixins

Config extensions for a given machine.

- `mixins-cloud-init` enables [cloud-init](https://cloud-init.io)
- `mixins-systemd-boot` configure systemd-boot as bootloader
- `mixins-telegraf` enables a generic telegraf configuration. See [Mic's dotfiles](https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix)
  for monitoring rules targeting this telegraf configuration.
- `mixins-nginx` recommended nginx settings
- `mixins-trusted-nix-caches` list of trust-worthy public binary caches

### Roles

Designed to take over a machine with the given role.

- `roles-github-actions-runner` configures GitHub actions runner on a machine

## License

[MIT](LICENSE)

***

This is a [Numtide](https://numtide.com) project.

<img src="https://numtide.com/logo.png" alt="NumTide Logo" width="80">

# srvos

STATUS: **experimental**

Opinionated and sharable set of NixOS configurations.

As we learn more about NixOS in various deployments, we end up re-writing the same modules and configs. This is a way for us to speed up and share our setups.

## Installation

Add `srvos` to your flake.nix and include it in your nixos configuration like this:

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
      ];
    };
  };
}
```

## Modules

All modules are defined in this [file](default.nix)

- common, desktop, server - Used to define the type of machine.
  - `server`:
    - Use this for headless systems that are remotly managed via ssh
    - Includes everything from common
    - Disables desktop features like sound
    - Defaults to UTC
    - Enables ssh
    - Configures watchdog for reboot
    - Sets up sudo without password
    - ...
  - `desktop`:
    - Mostly based on common but also includes some optimation for useful for interactive usage
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
- hardware - NixOS hardware configurations.
  - `hardware-amazon`: Amazon AWS virtual machines
  - `hardware-hetzner-cloud`: Hardware and network defaults for Hetzner virtual machine
  - `hardware-hetzner-amd`, `hardware-hetzner-intel`: Hardware and network defaults for Hetzner bare-metal servers for AMD and Intel cpus.
- mixins - config extensions for a given machine.
  - `mixins-cloud-init` enables [cloud-init](https://cloud-init.io)
  - `mixins-systemd-boot` configure systemd-boot as bootloader
  - `mixins-telegraf` enables a generic telegraf configuration. See [Mic's dotfiles](https://github.com/Mic92/dotfiles/blob/master/nixos/eva/modules/prometheus/alert-rules.nix)
    for monitoring rules targeting this telegraf configuration.
  - `mixins-nginx` recommended nginx settings
- roles - designed to take over a machine with the given role.
  - `roles-github-actions-runner` configures github actions runner on a machine

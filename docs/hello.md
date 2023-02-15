# Hello

SrvOS is a collection of opinionated and sharable NixOS configurations.

As we learn more about NixOS in various deployments, we end up re-writing the same modules and configs. This is a way for us to speed up and share our setups.

Instead of supporting everything, our goal is to target certain verticals and make the support super smooth there.

## Quick Usage

Add `srvos` to your `flake.nix` to augment your NixOS configuration. For
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

## Technologies

SrvOS is a thin wrapper, sitting on the shoulder of others:

* [Nix and NixOS](https://nixos.org) of course.
* [nixos-anywhere](https://github.com/numtide/nixos-anywhere) to bootstrap new systems.
* [disko](https://github.com/nix-community/disko) to partition and configure disks.
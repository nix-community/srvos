# SrvOS - NixOS for your server

STATUS: **experimental**

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

For more usage and documentation in general, see <https://numtide.github.io/srvos/>.

## Known limitations

The current modules are only tested to work on the NixOS unstable release.
When updating srvos, we commend that you follow the same pin of nixpkgs that
is being used by this project.

## License

[MIT](LICENSE)

***

This is a [Numtide](https://numtide.com) project.

<img src="https://numtide.com/logo.png" alt="NumTide Logo" width="80">

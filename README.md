# SrvOS - NixOS profiles for servers

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

## Documentation

The [Documentation](https://numtide.github.io/srvos/) website shows more general usage, how to install SrvOS, etc...

To improve the documentation, take a look at the `./docs` folder. You can also run `nix run .#docs.serve` to start a preview server on <http://localhost:3000>.

## Contributing

Contributions are always welcome.

## License

[MIT](LICENSE)

***

This is a [Numtide](https://numtide.com) project.

<img src="https://numtide.com/logo.png" alt="NumTide Logo" width="80">

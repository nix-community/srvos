# SrvOS - NixOS profiles for servers

STATUS: stable

SrvOS is a collection of opinionated and sharable NixOS configurations.

As we learn more about NixOS in various deployments, we end up re-writing the same modules and configs. This is a way for us to speed up and share our setups.

Instead of supporting everything, our goal is to target certain verticals and make the support super smooth there.

## Quick Usage

Add `srvos` to your `flake.nix` to augment your NixOS configuration. For
example to deploy a GitHub Action runner on Hetzner:

```nix
{
  description = "My machines flakes";
  inputs = {
    srvos.url = "github:numtide/srvos";
    # Use the version of nixpkgs that has been tested to work with SrvOS
    # Alternativly we also support the latest nixos release and unstable
    nixpkgs.follows = "srvos/nixpkgs";
  };
  outputs = { self, nixpkgs, srvos }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # This machine is a server
        srvos.nixosModules.server
        # Deployed on the AMD Hetzner hardware
        srvos.nixosModules.hardware-hetzner-amd
        # Configured with extra terminfos
        srvos.nixosModules.mixins-terminfo
        # And designed to run the GitHub Actions runners
        srvos.nixosModules.roles-github-actions-runner
        # Finally add your configuration here
        ./myHost.nix
      ];
    };
  };
}
```

## Documentation

The [Documentation](https://nix-community.github.io/srvos/) website shows more general usage, how to install SrvOS, etc...

To improve the documentation, take a look at the `./docs` folder. You can also run `nix run .#docs.serve` to start a preview server on <http://localhost:3000>.

## Contributing

Contributions are always welcome!

## Commercial support

Looking for help or customization?

Get in touch with Numtide to get a quote. We make it easy for companies to
work with Open Source projects: <https://numtide.com/contact>

## License

[MIT](LICENSE)

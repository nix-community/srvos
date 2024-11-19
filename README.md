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
    srvos.url = "github:nix-community/srvos";
    # Use the version of nixpkgs that has been tested to work with SrvOS
    # Alternatively we also support the latest nixos release and unstable
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

## Non-flake usage

1. Pull the repo with your preferred tool (eg: [niv](https://github.com/nmattia/niv)
2. import the top-level `default.nix` in your code. You'll have access to the same modules as in the flake.

## Documentation

The [Documentation](https://nix-community.github.io/srvos/) website shows more general usage, how to install SrvOS, etc...

To improve the documentation, take a look at the `./docs` folder. You can also run `nix develop .#mkdocs -c mkdocs serve` to start a preview server on <http://localhost:8000>.


## Contributing

Contributions are always welcome!

## License

[MIT](LICENSE)

---

This project is supported by [Numtide](https://numtide.com/).
![Untitledpng](https://codahosted.io/docs/6FCIMTRM0p/blobs/bl-sgSunaXYWX/077f3f9d7d76d6a228a937afa0658292584dedb5b852a8ca370b6c61dabb7872b7f617e603f1793928dc5410c74b3e77af21a89e435fa71a681a868d21fd1f599dd10a647dd855e14043979f1df7956f67c3260c0442e24b34662307204b83ea34de929d)

We are a team of independent freelancers that love open source.  We help our
customers make their project lifecycles more efficient by:

- Providing and supporting useful tools such as this one
- Building and deploying infrastructure, and offering dedicated DevOps support
- Building their in-house Nix skills, and integrating Nix with their workflows
- Developing additional features and tools
- Carrying out custom research and development.

[Contact us](https://numtide.com/contact) if you have a project in mind, or if
you need help with any of our supported tools, including this one. We'd love to
hear from you.

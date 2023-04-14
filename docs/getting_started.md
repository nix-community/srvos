# Getting Started with SrvOS

This project is designed to work in combination with [NixOS](https://nixos.org).

In this documentation, we expect the reader to be already familiar with the base operating system, and introduce how to compose it with our own extensions.

## Finding your way around

This project exports four big categories of NixOS modules which are useful to define a server configuration:

* Machine type - these are high-level settings that define the machine type (Eg: common, server or desktop). Only one of those would be included.
* Machine hardware - these define hardware-releated settings for well known hardware. Only one of those would be included. (eg: AWS EC2 instances).
* Machine role - theses take over a machine for a specific role. Only one of those would be included. (eg: GitHub Actions runner)
* Configuration mixins - these define addons to be added to the machine configuration. One or more can be added.

## Example

Combining all of those together, here is how your `flake.nix` might look like, to deploy a GitHub Actions runner on Hetzner:

```nix
{
  description = "My machines flakes";
  inputs = {
    srvos.url = "github:numtide/srvos";
    # Use the version of nixpkgs that has been tested to work with SrvOS
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

## Continue

Now that we have gone over the high-level details, you should have an idea of how to use this project.

To dig further, take a look at the [User guide](user_guide.md).

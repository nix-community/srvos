# Using SrvOS with nix-darwin

## Finding your way around

This project exports four big categories of NixOS modules which are useful to define a server configuration:

* Machine type - these are high-level settings that define the machine type (Eg: common, server or desktop). Only one of those would be included.
* Configuration mixins - these define addons to be added to the machine configuration. One or more can be added.

## Example

Combining all of those together, here is how your `flake.nix` might look like, to deploy a GitHub Actions runner on Hetzner:

```nix
{
  description = "My machines flakes";
  inputs = {
    srvos.url = "github:nix-community/srvos/darwin-support";
    # Use the version of nixpkgs that has been tested to work with SrvOS
    # Alternatively we also support the latest nixos release and unstable
    nixpkgs.follows = "srvos/nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "srvos/nixpkgs";
  };
  outputs = { srvos, nix-darwin, ... }: {
    darwinConfigurations.myHost = nix-darwin.lib.darwinSystem {
      modules = [
        # This machine is a server (i.e. CI runner)
        srvos.darwinModules.server
        # If a machine is a workstation or laptop, use this instead
        # srvos.darwinModules.desktop

        # Configured with extra terminfos
        srvos.darwinModules.mixins-terminfo
        # Finally add your configuration here
        ./myHost.nix
      ];
    };
  };
}
```

## Continue

Now that we have gone over the high-level details, you should have an idea of how to use this project.

To dig further, take a look at the [User guide](../user_guide.md).

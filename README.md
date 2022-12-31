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

* common, desktop, server - Used to define the type of machine.
* mixins - config extensions for a given machine.
* roles - designed to take over a machine with the given role.


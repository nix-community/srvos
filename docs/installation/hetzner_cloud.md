# Hetzner Cloud installation

> ⚠️ Only works with VMs that have more than 2GB of RAM.

> ⚠️ This document reflects more of an ideal than reality right now.

1. Create the VM in Hetzner Cloud, get the IP, IPv6, set the SSH public key.
2. Create a new NixOS configuration in your flake:

```nix
{
  inputs.nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  inputs.srvos.url = "github:nix-community/srvos"; 
  inputs.disko.url = "github:nix-community/disko";

  outputs = { self, nixos-remote, srvos, disko, nixpkgs }@ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{ 
        imports = [ 
          srvos.nixosModules.hardware-hetzner-cloud
          srvos.nixosModules.server

          disko.nixosModules.disko
          ./myHost.nix
        ];
        networking.hostName = "my-host";
        # FIXME: Hetzner Cloud doesn't provide us with that configuration
        systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f9:c010:52fd::1/128";
      }];
    };
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShellNoCC {
        packages = [
          pkgs.nixos-rebuild
          nixos-anywhere.packages.${system}.default
        ];
      };
    });
  };
}
```

3. Update the hostname and IPv6 address in the config.

4. Bootstrap the NixOS deployment:
   ```console
   $ nix develop
   $ nixos-anywhere --flake .#my-host --target-host root@<ip_address>
   ```

🎉

5. Pick a nixos deployment tool of your choice! Eg:

   ```
   $ nixos-rebuild --flake .#my-host --target-host root@<ip_address> switch
   ```
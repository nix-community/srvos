# We use the darwinConfigurations to test all the modules below.
#
# This is not optimal, but it gets the job done
{
  inputs,
  self,
  pkgs,
}:
let
  lib = pkgs.lib;

  darwinSystem =
    args: import "${toString inputs.nix-darwin}/eval-config.nix" ({ inherit lib; } // args);

  # some example configuration to make it eval
  dummy =
    { config, ... }:
    {
      networking.hostName = "example-common";
      system.stateVersion = 5;

      # Don't reinstantiate nixpkgs for every eval.
      # Also important to have nixpkgs config which allows for some required insecure packages
      nixpkgs = {
        inherit pkgs;
      };
    };
in
{
  # General
  example-common = darwinSystem {
    modules = [
      dummy
      self.darwinModules.common
    ];
  };
  example-server = darwinSystem {
    modules = [
      dummy
      self.darwinModules.server
    ];
  };
  example-desktop = darwinSystem {
    modules = [
      dummy
      self.darwinModules.desktop
    ];
  };
  example-mixins-terminfo = darwinSystem {
    modules = [
      dummy
      self.darwinModules.mixins-terminfo
    ];
  };
  example-mixins-telegraf = darwinSystem {
    modules = [
      dummy
      self.darwinModules.mixins-telegraf
    ];
  };
  example-mixins-trusted-nix-caches = darwinSystem {
    modules = [
      dummy
      self.darwinModules.mixins-trusted-nix-caches
    ];
  };
}

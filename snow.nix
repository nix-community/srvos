inputs: { system, lib, pkgs }:
{
  gnuTools = lib.resurceIntoAttrs {
    hello = pkgs.mkDerivation {
      meta.platforms = [
        "x86_64-linux"
      ];
    };
  };

  # packages.${system}.gnuTools-hello

  lib = import ./lib { };

  myHost = pkgs.mkNixOS {
    imports = [

    ];

    meta.platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}

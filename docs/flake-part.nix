{ self, lib, ... }: {
  perSystem = { config, self', inputs', pkgs, ... }: {
    packages.docs = pkgs.callPackage ./. { };
  };
}

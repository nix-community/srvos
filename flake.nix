{
  description = "Server-optimized nixos configuration";

  outputs = { ... }: {
    nixosModules = {
      common = ./profiles/default.nix;
    };
  };
}

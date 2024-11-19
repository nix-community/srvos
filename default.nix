rec {
  modules.nixos = import ./nixos;
  modules.darwin = import ./darwin;

  # compat to current schema: `nixosModules` / `darwinModules`
  nixosModules = modules.nixos;
  darwinModules = modules.darwin;
}

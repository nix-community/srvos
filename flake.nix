{
  description = "Server-optimized nixos configuration";

  outputs = { self, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      nixosModules = {
        common = import ./profiles/default.nix;
        github-actions-runner = import ./roles/github-actions-runner.nix;
      };

      checks = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Some attributes needed
          defaults = {
            boot.loader.grub.devices = [ "/dev/sda" ];
            fileSystems."/".device = "/dev/sda";
            system.stateVersion = "22.11";
            users.users.root.password = "xxx";
          };

          testSystem = modules:
            (pkgs.nixos ([ defaults ] ++ modules)).config.system.build.toplevel;
        in
        {
          test-common = testSystem [ self.nixosModules.common ];
          test-github-actions-runner = testSystem [
            self.nixosModules.github-actions-runner
            {
              roles.github-actions-runner.cachix.cacheName = "cache-name";
              roles.github-actions-runner.cachix.tokenFile = "/run/cachix-token-file";
              roles.github-actions-runner.tokenFile = "/run/gha-token-file";
              roles.github-actions-runner.url = "https://fixup";
            }
          ];
        });
    };
}

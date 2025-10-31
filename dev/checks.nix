{
  prefix,
  self,
  pkgs,
}:
let
  lib = pkgs.lib;
  system = pkgs.stdenv.hostPlatform.system;

  nixosTest = import "${pkgs.path}/nixos/lib/testing-python.nix" { inherit pkgs system; };

  moduleTests = {
    "${prefix}-server" = nixosTest.makeTest {
      name = "${prefix}-server";

      nodes.machine =
        { ... }:
        {
          imports = [ self.nixosModules.server ];
          networking.hostName = "machine";
        };
      testScript = ''
        machine.wait_for_unit("sshd.service")
        # TODO: what else to test for?
      '';
    };
  };

  configurations = import ./test-configurations.nix { inherit self pkgs; };

  # Add all the nixos configurations to the checks
  nixosChecks = lib.mapAttrs' (name: value: {
    name = "${prefix}-${name}";
    value = value.config.system.build.toplevel;
  }) (lib.filterAttrs (_name: value: value != null) configurations);
in
nixosChecks // moduleTests

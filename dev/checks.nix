{ prefix, srvos, nixpkgs, system }:
let
  pkgs = nixpkgs.legacyPackages.${system};

  inherit (nixpkgs) lib;

  nixosTest = import "${pkgs.path}/nixos/lib/testing-python.nix" {
    inherit pkgs;
    system = pkgs.system;
  };

  moduleTests = {
    server = nixosTest.makeTest {
      name = "${prefix}-server";

      nodes.machine = { ... }: {
        imports = [ srvos.nixosModules.server ];
        networking.hostName = "machine";
      };
      testScript = ''
        machine.wait_for_unit("sshd.service")
        # TODO: what else to test for?
      '';
    };
  };

  configurations = import ./test-configurations.nix {
    inherit srvos nixpkgs system;
  };

  # Add all the nixos configurations to the checks
  nixosChecks =
    lib.mapAttrs'
      (name: value: { name = "${prefix}-${name}"; value = value.config.system.build.toplevel; })
      configurations;
in
nixosChecks // moduleTests

{ self, pkgs, system }:
let
  inherit (pkgs) lib;

  nixosTest = import "${pkgs.path}/nixos/lib/testing-python.nix" { inherit system pkgs; };

  moduleTests = {
    server = nixosTest.makeTest {
      name = "server";

      nodes.machine = { ... }: {
        imports = [ self.nixosModules.server ];
        networking.hostName = "machine";
      };
      testScript = ''
        machine.wait_for_unit("sshd.service")
        # TODO: what else to test for?
      '';
    };
  };

  # Only check the configurations for the current system
  sysConfigs = lib.filterAttrs (_name: value: value.pkgs.system == system) self.nixosConfigurations;

  # Add all the nixos configurations to the checks
  nixosChecks =
    lib.mapAttrs'
      (name: value: { name = "nixos-${name}"; value = value.config.system.build.toplevel; })
      sysConfigs;
in
nixosChecks // (lib.optionalAttrs pkgs.stdenv.isLinux moduleTests)

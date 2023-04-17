{ self, pkgs, system }:
let
  inherit (pkgs) lib;
  join = lib.concatStringsSep;
  keys = lib.attrNames;

  borsChecks =
    map (name: ''  "check ${name} [${system}]"'') (keys self.checks.${system} or { })
    ++
    map (name: ''  "nixosConfig ${name}"'') (keys self.nixosConfigurations or { })
    ++
    map (name: ''  "package ${name} [${system}]"'') (keys self.packages.${system} or { })
  ;

  borsTOML = pkgs.writeText "bors.toml" ''
    # Generated with ./bors.toml.sh
    cut_body_after = "" # don't include text from the PR body in the merge commit message
    status = [
      "Evaluate flake.nix",
      ${join ",\n  " borsChecks},
    ]
  '';

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
in
{
  # Check if the bors.toml needs to be updated
  testBorsTOML = pkgs.runCommand
    "test-bors-toml"
    {
      passthru.borsTOML = borsTOML;
    }
    ''
      if ! diff ${../bors.toml} ${borsTOML}; then
        echo "The generated ./bors.toml is out of sync"
        echo "Run ./bors.toml.sh to fix the issue"
        exit 1
      fi
      touch $out
    '';

} // (lib.optionalAttrs pkgs.stdenv.isLinux moduleTests)

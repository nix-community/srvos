{ self, pkgs, system }:
let
  inherit (pkgs) lib;
  join = lib.concatStringsSep;
  keys = lib.attrNames;

  borsChecks =
    map (name: ''  "check ${name} [${system}]"'') (keys self.checks.${system})
    ++
    map (name: ''  "nixosConfig ${name}"'') (keys self.nixosConfigurations)
    ++
    map (name: ''  "package ${name} [${system}]"'') (keys self.packages.${system})
  ;

  borsTOML = pkgs.writeText "bors.toml" ''
    # Generated with ./bors.toml.sh
    cut_body_after = "" # don't include text from the PR body in the merge commit message
    status = [
      "Evaluate flake.nix",
      ${join ",\n  " borsChecks},
    ]
  '';
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
}

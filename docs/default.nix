{ lib
, coreutils
, runCommand
, writeShellScriptBin
, mdbook
}:
runCommand
  "srvos-docs"
{
  passthru.serve = writeShellScriptBin "serve" ''
    set -euo pipefail
    cd docs
    workdir=$(${coreutils}/bin/mktemp -d)
    trap 'rm -rf "$workdir"' EXIT
    ${lib.getExe mdbook} serve --dest-dir "$workdir"
  '';
}
  ''
    cp -r ${lib.cleanSource ./.}/* .
    ${lib.getExe mdbook} build --dest-dir "$out"
  ''

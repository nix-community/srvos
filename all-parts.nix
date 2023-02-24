# Find all the flake-part.nix files in this repo and import them
{ config, lib, ... }:
let
  root = ./.;

  getParts = path:
    let dir = builtins.readDir path; in
    lib.concatMap
      (k:
        let v = dir.${k}; in
        if k == "flake-part.nix" && v == "regular" then
        # Collect this
          [ (path + "/${k}") ]
        else if v == "directory" then
          getParts (path + "/${k}")
        else [ ]
      )
      (lib.attrNames dir);
in
{
  imports = getParts ./.;
}

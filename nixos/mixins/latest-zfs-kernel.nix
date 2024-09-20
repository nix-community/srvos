{ lib, pkgs, ... }:
let
  latestZfsCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
      (builtins.tryEval kPkgs).success
      && kPkgs ? kernel
      && kPkgs.kernel.pname == "linux"
      && !kPkgs.zfs.meta.broken
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
in
{
  # Note this might jump back and worth as kernel get added or removed.
  boot.kernelPackages = latestZfsCompatibleLinuxPackages;
}

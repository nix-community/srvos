{ lib, pkgs, ... }:
{
  # Configure so that we can use serial consoles.
  # This is for example important for IPMI SOL console redirection or GPIO-based ttl-converter
  boot.kernelParams =
    [ "console=ttyS0,115200" ] ++
    (lib.optional (pkgs.stdenv.hostPlatform.isAarch) "console=ttyAMA0,115200") ++
    (lib.optional (pkgs.stdenv.hostPlatform.isRiscV64) "console=ttySIF0,115200") ++
    [ "console=tty0" ];

  # also make grub respond on serial consoles
  boot.loader.grub.extraConfig = ''
    serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
    terminal_input --append serial
    terminal_output --append serial
  '';
}

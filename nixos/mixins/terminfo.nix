{
  pkgs,
  lib,
  ...
}:
{
  # various terminfo packages
  environment.systemPackages = [
    pkgs.wezterm.terminfo # this one does not need compilation
    # avoid compiling desktop stuff when doing cross nixos
    (pkgs.runCommand "ghostty-terminfo"
      {
        nativeBuildInputs = [ pkgs._7zz ];
      }
      ''
        7zz -snld x ${pkgs.ghostty-bin.src}
        mkdir -p $out/share/terminfo
        cp -r Ghostty.app/Contents/Resources/terminfo/* $out/share/terminfo/
      ''
    )
  ]
  ++ lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
    pkgs.foot.terminfo
    pkgs.kitty.terminfo
    pkgs.termite.terminfo
  ];
}

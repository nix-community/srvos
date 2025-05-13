{
  pkgs,
  lib,
  ...
}:
{
  # various terminfo packages
  environment.systemPackages =
    [
      pkgs.wezterm.terminfo # this one does not need compilation
      # avoid compiling desktop stuff when doing cross nixos
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) [
      pkgs.termite.terminfo
      # Too unstable
      # pkgs.kitty.terminfo
      pkgs.foot.terminfo
      pkgs.ghostty.terminfo
    ];
}

{ pkgs
, config
, lib
, ...
}: {
  programs.bcc.enable = !pkgs.stdenv.hostPlatform.isRiscV;
  programs.sysdig.enable = !pkgs.stdenv.isAarch64 && !pkgs.stdenv.hostPlatform.isRiscV;

  environment.systemPackages = [
    pkgs.strace

    # low priority so that we can to use trace from bcc
    (pkgs.lowPrio config.boot.kernelPackages.perf)
  ];
}

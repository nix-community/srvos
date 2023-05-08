let
  inherit (builtins)
    listToAttrs
    replaceStrings
    stringLength
    substring
    ;

  removeSuffix =
    # Suffix to remove if it matches
    suffix:
    # Input string
    str:
    let
      sufLen = stringLength suffix;
      sLen = stringLength str;
    in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str then
      substring 0 (sLen - sufLen) str
    else
      str;

  # Map 1:1 between paths and modules
  exposeModules = baseDir: paths:
    let
      prefix = stringLength (toString baseDir) + 1;

      toPair = path: {
        name = replaceStrings [ "/" ] [ "-" ] (removeSuffix ".nix" (substring prefix 1000000
          (toString path)));
        value = path;
      };
    in
    listToAttrs (map toPair paths)
  ;

in
exposeModules ./. [
  ./common
  ./desktop
  ./hardware/amazon
  ./hardware/hetzner-cloud
  ./hardware/hetzner-online/amd.nix
  ./hardware/hetzner-online/intel.nix
  ./hardware/vultr/bare-metal.nix
  ./hardware/vultr/vm.nix
  ./mixins/cloud-init.nix
  ./mixins/nginx.nix
  ./mixins/systemd-boot.nix
  ./mixins/telegraf.nix
  ./mixins/terminfo.nix
  ./mixins/tracing.nix
  ./mixins/trusted-nix-caches.nix
  ./roles/github-actions-runner.nix
  ./roles/nix-remote-builder.nix
  ./server
]

let
  exposeModules = import ../lib/exposeModules.nix;
in
exposeModules ./. [
  ./common
  ./server
  ./desktop
  ./mixins/nix-experimental.nix
  ./mixins/telegraf.nix
  ./mixins/terminfo.nix
  ./mixins/trusted-nix-caches.nix
]

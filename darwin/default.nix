let
  exposeModules = import ../lib/exposeModules.nix;
in
exposeModules ./. [
  ./common
  ./server
  ./desktop
  ./mixins/telegraf.nix
  ./mixins/terminfo.nix
]

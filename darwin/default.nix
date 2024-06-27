let
  exposeModules = import ../lib/exposeModules.nix;
in
exposeModules ./. [
  ./common
  ./mixins/telegraf.nix
  ./mixins/terminfo.nix
]

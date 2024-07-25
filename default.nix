# This file provides backward compatibility to nix < 2.4 clients
{
  system ? builtins.currentSystem,
  src ? ./.,
}:
let
  lock = builtins.fromJSON (builtins.readFile ./dev/private/flake.lock);
  inherit (lock.nodes.flake-compat.locked)
    owner
    repo
    rev
    narHash
    ;

  flake-compat = fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };

  flake = import flake-compat { inherit src system; };
in
flake.defaultNix

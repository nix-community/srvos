# This file provides backward compatibility to nix < 2.4 clients
{ system ? builtins.currentSystem }:
let
  snowSrc =
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
    fetchTarball {
      url =
        "https://github.com/numtide/snow/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 =
        lock.nodes.snow.locked.narHash;
    };

  snow = import "${toString snowSrc}/lib";
in
snow.plow { src = ./.; inherit system; }

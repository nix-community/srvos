# This file provides backward compatibility to nix < 2.4 clients
{ system ? builtins.currentSystem }:
let
  # FIXME: replace once snow is moved out of the repo
  snowSrc = ./snow;

  snow = import "${toString snowSrc}/lib";
in
snow.plow { src = ./.; inherit system; }

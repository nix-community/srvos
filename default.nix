# This file provides backward compatibility to nix < 2.4 clients
{ system ? builtins.currentSystem }:
let
  flake-compat = builtins.fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9.tar.gz";
    sha256 = "sha256-4gtG9iQuiKITOjNQQeQIpoIB6b16fm+504Ch3sNKLd8=";
  };

  flake = import flake-compat { src = ./.; inherit system; };
in
flake.defaultNix

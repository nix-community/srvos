{ system ? builtins.currentSystem }:
let
  d = import ./. { inherit system; src = ./dev; };
in
d.devShells.${system}.default

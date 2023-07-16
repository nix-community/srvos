{ system ? builtins.currentSystem }:
let
  devFlake = builtins.getFlake (toString ./.);
in
devFlake.checks.${system}

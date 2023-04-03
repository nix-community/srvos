{ system ? builtins.currentSystem }:
let
  rootFlake = builtins.getFlake (toString ./..);
  devFlake = builtins.getFlake (toString ./.);
in
(rootFlake.checks.${system}) // (devFlake.checks.${system})

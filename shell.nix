{ system ? builtins.currentSystem }:
(import ./default.nix { inherit system; }).devShells.${system}.default
or throw "dev-shell not defined. Cannot find flake attribute devShells.${system}.default"
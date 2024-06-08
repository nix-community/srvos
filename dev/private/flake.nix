{
  description = "srvos private inputs";

  inputs.nixos-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "";

  inputs.mkdocs-numtide.url = "github:numtide/mkdocs-numtide";
  inputs.mkdocs-numtide.inputs.nixpkgs.follows = "nixos-stable";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "";

  inputs.pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  inputs.pre-commit-hooks-nix.inputs.flake-compat.follows = "flake-compat";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs.follows = "";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs-stable.follows = "";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixos-stable";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { ... }: { };
}

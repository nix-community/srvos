{
  description = "srvos private inputs";

  # follows the same channel as nixpkgs in the main flake
  inputs.nixpkgs-dev.url = "github:NixOS/nixpkgs/nixos-unstable-small";

  inputs.nixos-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

  inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  inputs.nix-darwin.inputs.nixpkgs.follows = "";

  inputs.mkdocs-numtide.url = "github:numtide/mkdocs-numtide";
  inputs.mkdocs-numtide.inputs.nixpkgs.follows = "nixpkgs-dev";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "";

  inputs.git-hooks-nix.url = "github:cachix/git-hooks.nix";
  inputs.git-hooks-nix.inputs.flake-compat.follows = "flake-compat";
  inputs.git-hooks-nix.inputs.nixpkgs.follows = "";
  inputs.git-hooks-nix.inputs.nixpkgs-stable.follows = "";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-dev";

  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { ... }: { };
}

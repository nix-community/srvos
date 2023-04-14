Some questions and answers that haven't been integrated in the documentation yet.

## What version of NixOS should I use?

SrvOS is currently only tested against `nixos-unstable`. SrvOS itself is automatically updated and tested against the latest version of that channel once a week.

If you want to make sure to use a tested version, use the "follows" mechanims of Nix flakes to pull the same version as the one of SrvOS:

```nix
{
  inputs.srvos.url = "github:numtide/srvos";
  # Use the version of nixpkgs that has been tested to work with SrvOS
  inputs.nixpkgs.follows = "srvos/nixpkgs";
}
```
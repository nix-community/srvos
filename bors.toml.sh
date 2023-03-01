#!/usr/bin/env bash
# Used to generate the bors.toml file
set -euo pipefail

cd "$(dirname "$0")"

# Generate the bors.toml from the config
nix build ".#checks.x86_64-linux.testBorsTOML.passthru.borsTOML"

# Copy
cp --no-preserve=mode ./result bors.toml

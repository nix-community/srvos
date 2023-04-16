#!/usr/bin/env bash
# Get the latest modules list from nixpkgs and reset all the simplifications
# that were found.
#
# Run ./reduce.sh to re-calculate the needed list.
set -euo pipefail

cd "$(dirname "$0")"

# Find the path to nixpkgs using the flake input
nixpkgs=$(nix eval --expr "toString (builtins.getFlake (toString ../../.)).inputs.nixpkgs" --impure --raw)

modulePath="${nixpkgs}/nixos/modules/module-list.nix"

# Convert the module-list to JSON
awk '/^  \.\// { print substr($1, 3) }' "$modulePath" | jq -nR '[inputs]' > ./module-list.json

# Modules we tested are needed
echo "[]" > ./module-needed.json

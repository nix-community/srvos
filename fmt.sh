#!/usr/bin/env bash
set -euo pipefail
exec nix run "path:$(dirname "$0")/dev#treefmt" --override-input srvos "path:$PWD" -- "$@"

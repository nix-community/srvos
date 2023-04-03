#!/usr/bin/env bash
set -euo pipefail
exec nix run "path:$(dirname "$0")#treefmt" --override-input srvos "path:$(dirname "$0")/.." -- "$@"

#!/usr/bin/env bash
set -euo pipefail

nix develop "$(dirname "$0")" --override-input srvos "path:$(dirname "$0")/.." "$@"

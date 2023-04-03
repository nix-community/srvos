#!/usr/bin/env bash
set -euo pipefail

args=(
  "$@"
  --accept-flake-config
  --max-memory-size "12000"
  --option allow-import-from-derivation false
  --show-trace
  --workers 4
  "$(dirname "$0")"/ci.nix
)

if [[ -n ${GITHUB_STEP_SUMMARY-} ]]; then
  log() {
    echo "$*" >>"$GITHUB_STEP_SUMMARY"
  }
else
  log() {
    echo "$*"
  }
fi

# Update srvos to the latest hash
nix flake lock "$(dirname "$0")" --update-input srvos

error=0

for job in $(nix-eval-jobs "${args[@]}" | jq -r '. | @base64'); do
  job=$(echo "$job" | base64 -d)
  attr=$(echo "$job" | jq -r .attr)
  echo "### $attr"
  errMsg=$(echo "$job" | jq -r .error)
  if [[ $errMsg != null ]]; then
    log "### ❌ $attr"
    log
    log "<details><summary>Eval error:</summary><pre>"
    log "$error"
    log "</pre></details>"
    error=1
  else
    drvPath=$(echo "$job" | jq -r .drvPath)
    if ! nix-store --realize "$drvPath" 2>&1 | tee build-log.txt; then
      log "### ❌ $attr"
      log
      log "<details><summary>Build error:</summary>last 50 lines:<pre>"
      log "$(tail -n 50 build-log.txt)"
      log "</pre></details>"
      error=1
    else
      log "### ✅ $attr"
    fi
    log
    rm build-log.txt
  fi
done

# TODO: improve the reporting
exit "$error"

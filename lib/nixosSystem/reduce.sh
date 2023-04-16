#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[script] $*" >&2
}

run_check() {
  nix build ".#nixosConfigurations.example-server.config.system.build.toplevel" && \
  nix flake check
}

cd "$(dirname "$0")"

if ! run_check ; then
  log "fix the flake before starting this process"
  exit 1
fi

modList=./module-list.json
modNeeded=./module-needed.json

while true; do
  len=$(jq '. | length' < $modList)
  if [[ $len -eq 0 ]]; then
    log "All done!"
    exit
  fi
  modulePath=$(jq -r '. | last' < $modList)
  newList=$(jq 'del(.[-1])' < $modList)
  echo "$newList" > $modList

  log "path=$modulePath remaining=$len"

  if run_check; then
    log "path=$modulePath status=not needed"
  else
    log "path=$modulePath status=needed"
    newList=$(jq --arg modulePath "$modulePath" '. += [$modulePath] | sort' < $modNeeded)
    echo "$newList" > $modNeeded
  fi
done



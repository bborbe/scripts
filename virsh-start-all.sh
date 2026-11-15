#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# VMs deliberately NOT started by this script -- i.e. not part of the set that
# normally runs. Start them by hand with `virsh start <vm>` when needed.
# Empty since 2026-11-15: nuke-boss, nuke-workspace, nuke-k3s-agent-0,
# nuke-k3s-dev-0 and nuke-k3s-prod-0 were undefined and their LVs removed.
EXCLUDE=()

for vm in $(virsh list --state-shutoff --name); do
  skip=0
  for ex in "${EXCLUDE[@]+"${EXCLUDE[@]}"}"; do
    if [[ "$vm" == "$ex" ]]; then
      skip=1
      break
    fi
  done
  if [[ $skip -eq 1 ]]; then
    echo "skip $vm (excluded)"
    continue
  fi
  virsh start "$vm"
done

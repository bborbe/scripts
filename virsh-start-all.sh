#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# VMs deliberately NOT started by this script -- i.e. not part of the set that
# normally runs. Start them by hand with `virsh start <vm>` when needed.
#   nuke-boss, nuke-workspace       -- started on demand
#   nuke-k3s-prod, nuke-k3s-dev     -- old single-node clusters, destroyed 2026-07-20
#   nuke-k3s-dev-0                  -- DRAINED AND SHUT DOWN 2026-08-20 after the whole
#                                      dev stack (trading + agent platform) moved to the
#                                      nuke-dev cluster. Still DEFINED on purpose: its
#                                      disk holds ~460 GB of retained source PVCs, the
#                                      fallback for every migration batch. Do not
#                                      undefine or remove the LV until prod has migrated
#                                      too and the fallback is genuinely not needed.
EXCLUDE=(nuke-boss nuke-workspace nuke-k3s-prod nuke-k3s-dev nuke-k3s-dev-0)

for vm in $(virsh list --state-shutoff --name); do
  skip=0
  for ex in "${EXCLUDE[@]}"; do
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

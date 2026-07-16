#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

EXCLUDE=(nuke-boss nuke-workspace nuke-k3s-longhorn-0 nuke-k3s-longhorn-1)

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

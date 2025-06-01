#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

for vm in $(virsh list --all --name); do
  virsh start "$vm"
done

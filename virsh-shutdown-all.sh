#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

virsh list --all | grep 'running' | awk '{print $2}' | xargs --no-run-if-empty -t -I {} virsh shutdown {}

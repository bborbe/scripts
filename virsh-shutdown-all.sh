#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

virsh list --state-running --name | xargs --no-run-if-empty -t -I {} virsh shutdown {}

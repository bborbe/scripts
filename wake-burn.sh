#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# eth0
etherwake 00:1f:d0:5c:2a:8d
wakeonlan 00:1f:d0:5c:2a:8d
# eth1
etherwake 00:1f:d0:80:16:95
wakeonlan 00:1f:d0:80:16:95

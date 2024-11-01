#!/usr/bin/env bash

set -o nounset
set -o pipefail

systemctl stop k3s
systemctl stop k3s-agent
/usr/local/bin/k3s-killall.sh
mkdir -p /var/lib/rancher/k3s/storage
mount /var/lib/rancher/k3s/storage
echo "done"

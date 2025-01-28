#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
parallel-ssh -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
	-H fire-k3s-longhorn-0.hm.benjamin-borbe.de \
	-H fire-k3s-longhorn-1.hm.benjamin-borbe.de \
	-H fire-k3s-longhorn-2.hm.benjamin-borbe.de \
	"sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"

echo "shutdown k3s triggered"

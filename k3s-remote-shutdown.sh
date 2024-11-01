#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
/opt/local/bin/pssh -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
	-H fire-k3s-dev-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-dev-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-dev.hm.benjamin-borbe.de \
	-H fire-k3s-master.hm.benjamin-borbe.de \
	-H fire-k3s-prod-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-prod-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-prod.hm.benjamin-borbe.de \
	"sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"


echo "shutdown k3s triggered"

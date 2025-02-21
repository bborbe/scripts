#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
parallel-ssh -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
  -H nuke-k3s-agent-0.hm.benjamin-borbe.de \
  -H nuke-k3s-agent-1.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-capitalcom.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-core.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-frontend.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-misc.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-mt5.hm.benjamin-borbe.de \
  -H nuke-k3s-kafka-0.hm.benjamin-borbe.de \
  -H nuke-k3s-kafka-1.hm.benjamin-borbe.de \
  -H nuke-k3s-kafka-2.hm.benjamin-borbe.de \
  -H nuke-k3s-longhorn-0.hm.benjamin-borbe.de \
  -H nuke-k3s-longhorn-1.hm.benjamin-borbe.de \
  -H nuke-k3s-master-0.hm.benjamin-borbe.de \
  -H nuke-k3s-master-1.hm.benjamin-borbe.de \
  -H nuke-k3s-master-2.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-capitalcom.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-core.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-frontend.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-misc.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-mt5.hm.benjamin-borbe.de \
	"sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"


echo "shutdown k3s triggered"

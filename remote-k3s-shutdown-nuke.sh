#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CMD=pssh
if which parallel-ssh &> /dev/null; then
    CMD=parallel-ssh
fi

# -P
$CMD -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
  -H nuke-k3s-agent-0.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-0.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-0.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-worker-0.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-worker-0.hm.benjamin-borbe.de \
  "sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"

$CMD -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
  -H nuke-k3s-kafka-0.hm.benjamin-borbe.de \
  -H nuke-k3s-kafka-1.hm.benjamin-borbe.de \
  -H nuke-k3s-kafka-2.hm.benjamin-borbe.de \
  "sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"

$CMD -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
  -H nuke-k3s-master-0.hm.benjamin-borbe.de \
  -H nuke-k3s-master-1.hm.benjamin-borbe.de \
  -H nuke-k3s-master-2.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-master-0.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-master-0.hm.benjamin-borbe.de \
  "sudo systemctl stop k3s;sudo systemctl stop k3s-agent;sudo /usr/local/bin/k3s-killall.sh;sudo mkdir -p /var/lib/rancher/k3s/storage;sudo mount /var/lib/rancher/k3s/storage;echo done"

echo "shutdown k3s triggered"

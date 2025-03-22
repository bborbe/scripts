#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CMD=pssh
if which parallel-ssh &> /dev/null; then
    CMD=parallel-ssh
fi

# -P
$CMD -o /tmp/pssh.log -l bborbe -t 300 -p 100 \
	-H co2hz.hm.benjamin-borbe.de \
	-H co2wz.hm.benjamin-borbe.de \
	-H fire.hm.benjamin-borbe.de \
	-H hell.hm.benjamin-borbe.de \
	-H hetzner-1.benjamin-borbe.de \
	-H nuke-k3s-agent-0.hm.benjamin-borbe.de \
	-H nuke.hm.benjamin-borbe.de \
	-H rasp3.hm.benjamin-borbe.de \
  -H nuke-k3s-agent-1.hm.benjamin-borbe.de \
  -H nuke-k3s-dev-0.hm.benjamin-borbe.de \
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
  -H nuke-k3s-prod-0.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-capitalcom.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-core.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-frontend.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-misc.hm.benjamin-borbe.de \
  -H nuke-k3s-prod-mt5.hm.benjamin-borbe.de \
	"sudo dpkg --configure -a && sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get clean"

echo "run port selfupdate"
sudo port selfupdate
sudo port upgrade outdated
sudo port installed | grep -v ' (active)'|grep -v 'The following ports are currently installed:' | xargs --no-run-if-empty sudo port uninstall 
sudo port clean all
pyenv update

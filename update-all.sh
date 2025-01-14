#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
/opt/local/bin/pssh -o /tmp/pssh.log -l bborbe -t 300 -p 100 \
	-H co2hz.hm.benjamin-borbe.de \
	-H co2wz.hm.benjamin-borbe.de \
	-H fire-k3s-dev-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-dev-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-dev.hm.benjamin-borbe.de \
<<<<<<< HEAD
	-H fire-k3s-longhorn-0.hm.benjamin-borbe.de \
	-H fire-k3s-longhorn-1.hm.benjamin-borbe.de \
=======
	-H fire-k3s-longhorn.hm.benjamin-borbe.de \
>>>>>>> origin/master
	-H fire-k3s-master.hm.benjamin-borbe.de \
	-H fire-k3s-prod-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-prod-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-prod.hm.benjamin-borbe.de \
	-H fire.hm.benjamin-borbe.de \
	-H hell.hm.benjamin-borbe.de \
	-H hetzner-1.benjamin-borbe.de \
	-H nuke-k3s-agent.hm.benjamin-borbe.de \
	-H nuke.hm.benjamin-borbe.de \
	-H rasp3.hm.benjamin-borbe.de \
	-H rasp4.hm.benjamin-borbe.de \
	"sudo dpkg --configure -a && sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get clean"

echo "run port selfupdate"
sudo port selfupdate
sudo port upgrade outdated
sudo port installed | grep -v ' (active)'|grep -v 'The following ports are currently installed:' | xargs --no-run-if-empty sudo port uninstall 
sudo port clean all
pyenv update

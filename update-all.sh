#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
pssh -o /tmp/pssh.log -l bborbe -t 300 -p 100 \
	-H co2hz.hm.benjamin-borbe.de \
	-H co2wz.hm.benjamin-borbe.de \
	-H rasp3.hm.benjamin-borbe.de \
	-H rasp4.hm.benjamin-borbe.de \
	-H fire.hm.benjamin-borbe.de \
	-H nuke.hm.benjamin-borbe.de \
	-H sun.pn.benjamin-borbe.de \
	-H v22016124049440903.goodsrv.de \
	-H hetzner-1.benjamin-borbe.de \
	"sudo dpkg --configure -a && sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get clean"

echo "run port selfupdate"
sudo port selfupdate
sudo port upgrade outdated
sudo port uninstall `sudo port installed | grep -v ' (active)'`
sudo port clean all
pyenv update

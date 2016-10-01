#!/bin/sh

# -P
pssh -o /tmp/pssh.log -l bborbe -t 300 -p 100 \
	-H rasp.hm.benjamin-borbe.de \
	-H fire.hm.benjamin-borbe.de \
	-H backup.pn.benjamin-borbe.de \
	-H sun.pn.benjamin-borbe.de \
	-H iredmail.mailfolder.org \
	-H host.rocketsource.de \
	-H tools.seibert-media.net \
	"sudo dpkg --configure -a && sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove && sudo apt-get clean"

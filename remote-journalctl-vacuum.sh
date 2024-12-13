#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# -P
/opt/local/bin/pssh -o /tmp/pssh-k3s.log -l bborbe -t 300 -p 100 \
	-H fire.hm.benjamin-borbe.de \
	-H fire-k3s-dev-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-dev-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-dev.hm.benjamin-borbe.de \
	-H fire-k3s-master.hm.benjamin-borbe.de \
	-H fire-k3s-prod-capitalcom.hm.benjamin-borbe.de \
	-H fire-k3s-prod-mt5.hm.benjamin-borbe.de \
	-H fire-k3s-prod.hm.benjamin-borbe.de \
	-H fire-k3s-agent.hm.benjamin-borbe.de \
	"sudo journalctl --vacuum-size=1M"


echo "journalctl vacuum-size triggered"

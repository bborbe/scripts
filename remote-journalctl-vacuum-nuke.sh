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
	-H nuke.hm.benjamin-borbe.de \
	"sudo journalctl --vacuum-size=1M"


echo "journalctl vacuum-size triggered"

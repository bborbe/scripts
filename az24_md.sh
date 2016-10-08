#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

ticket=$1
echo "ticket ${ticket}"

mkdir -p /Users/bborbe/Documents/Seibert-Media/Projects/Allianz/${ticket}
filename="/Users/bborbe/Documents/Seibert-Media/Projects/Allianz/${ticket}/${ticket}.md"

if [ ! -f "${filename}" ]; then
	echo "create ${filename}"
	cat /Users/bborbe/Documents/Seibert-Media/Projects/Allianz/template.md | sed -e "s,TICKET,${ticket},g;" > ${filename}
fi

echo "open ${filename}"
# open ${filename}
ec ${filename} &

cd $AZ24_HOME/allsecur-application/
git checkout -b feature/${ticket} && git push --set-upstream origin feature/${ticket} || true
git checkout feature/${ticket}

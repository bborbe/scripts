#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

server="ns.rocketsource.de"
key="$HOME/.dns/home.benjamin-borbe.de"
zone="nuke.hm.benjamin-borbe.de."
node="_acme-challenge"
ttl='60'
class='TXT'

echo "update ${node}.${zone} ${ttl} ${class} started"

tmpfile=$(mktemp)
cat >$tmpfile <<END
server $server
update delete ${node}.${zone} $ttl $class
update add ${node}.${zone} $ttl $class w9H7iRXieF-_TXf0a5wFLkX61uSkU2SrRz1cX5Bvw6E
send
END
nsupdate -k ${key} -v $tmpfile
rm -f $tmpfile

echo "update ${node}.${zone} ${ttl} ${class} finished"

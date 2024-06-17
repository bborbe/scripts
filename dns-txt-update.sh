#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

server="ns.rocketsource.de"
key="/Users/bborbe/.dns/home.benjamin-borbe.de"
zone="fire.hm.benjamin-borbe.de."
node="_acme-challenge"
ttl='60'
class='TXT'

echo "update ${node}.${zone} ${ttl} ${class} started"

tmpfile=$(mktemp)
cat >$tmpfile <<END
server $server
update delete ${node}.${zone} $ttl $class
update add ${node}.${zone} $ttl $class Pbsxwj87v3RlXReHlT6Lk3htsauACtcsyC8IKud9gcU
update add ${node}.${zone} $ttl $class tMRRU1SLO1sBerRLNfpgma-UjCuLVk0PAk4DONGMvkw
send
END
nsupdate -k ${key} -v $tmpfile
rm -f $tmpfile

echo "update ${node}.${zone} ${ttl} ${class} finished"

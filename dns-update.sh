#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SERVER='ns.rocketnews.de'
TTL='86400'
KEY='/root/keys/Kserver1-ddns-key.+157+36654'
cmd=add
zone=$1
node=$2
data=$3
class='A'
tmpfile=$(mktemp)
cat >$tmpfile <<END
server $SERVER
update delete ${node}.${zone} $TTL $class
update add ${node}.${zone} $TTL $class $data
send
END
nsupdate -k $KEY -v $tmpfile
rm -f $tmpfile

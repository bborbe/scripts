#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SERVER='ns.rocketsource.de'
#TTL='86400'
TTL='60'
KEY='/root/keys/Kserver1-ddns-key.+157+36654'
zone=benjamin-borbe.de 
node=home
data=`curl -s https://www.benjamin-borbe.de/ip`
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

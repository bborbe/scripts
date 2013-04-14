#!/bin/bash
SERVER='ns.rocketnews.de'
TTL='86400'
KEY='/root/keys/Kserver1-ddns-key.+157+36654'
cmd=$1
zone=$2
node=$3
data=$4

cmd=add 
zone=benjamin-borbe.de 
node=home
data=`curl http://ip.benjamin-borbe.de`
class='A'
tmpfile=$(mktemp)
cat >$tmpfile <<END
server $SERVER
update $cmd ${node}.${zone} $TTL $class $data
send
END
nsupdate -k $KEY -v $tmpfile
rm -f $tmpfile

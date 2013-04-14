#!/bin/bash
SERVER='ns.rocketnews.de'
TTL='86400'
KEY='/root/keys/Kserver1-ddns-key.+157+36654'
zone=benjamin-borbe.de 
node=home
data=`curl -s http://ip.benjamin-borbe.de`
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

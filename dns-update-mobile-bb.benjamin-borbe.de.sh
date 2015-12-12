#!/bin/bash
SERVER='ns.rocketsource.de'
#TTL='86400'
TTL='60'
KEY="$HOME/.dns/Kserver1-ddns-key.+157+36654"
zone=benjamin-borbe.de
node=mobile-bb
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

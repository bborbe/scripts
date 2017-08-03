#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function help {
	echo "Usage: $0 [domain]" >&2
	exit 1
}

function check {
	domain=$1
	server=$2
	echo -n "check $domain on $server => "
	if host $domain $server  > /dev/null ; then
		echo 'success'
	else
		echo 'fail'
	fi
}

if [ $# -eq 0 ]; then
	help
fi

check $1 ''
check $1 ns.rocketsource.de
check $1 b.ns14.net
check $1 c.ns14.net
check $1 d.ns14.net
check $1 8.8.8.8
check $1 8.8.4.4

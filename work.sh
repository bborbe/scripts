#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function help {
	echo "Usage: $0 {start|stop}" >&2
	exit 1
}

if [ $# -eq 0 ]; then
	help
fi

case "$1" in
	start)
		echo "starting"
		app.sh start
		open -a IntelliJ\ IDEA -g
		open -a Discord -g
		open -a Google\ Chat -g
	;;
	stop)
		echo "stopping"
		app.sh stop
	;;
	*)
		help
	;;
esac

exit 0

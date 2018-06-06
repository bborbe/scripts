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
		open -a Telephone -g
		open -a Discord -g
	;;
	stop)
		echo "stopping"
		app.sh stop
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
	*)
		help
	;;
esac

exit 0

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
		open -a HipChat -g
#		open -a Chat -g
#		open -a Mattermost -g
		open -a zoiper -g
#		open -a Adium -g
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

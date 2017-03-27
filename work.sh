#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		app.sh start
		open -a HipChat -g
#		open -a Mattermost -g
		open -a zoiper -g
#		open -a Adium -g
	;;
	stop)
		echo "stopping"
		app.sh stop
	;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
	;;
esac

exit 0

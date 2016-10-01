#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		~/bin/app.sh start
		open -a Telephone -g
	;;
	stop)
		echo "stopping"
		~/bin/app.sh stop
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" >&2
		exit 1
	;;
esac

exit 0

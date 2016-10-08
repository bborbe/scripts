#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		sudo launchctl load -w /opt/local/etc/LaunchDaemons/org.macports.bind9/org.macports.bind9.plist 
	;;
	stop)
		echo "stopping"
		sudo launchctl unload -w /opt/local/etc/LaunchDaemons/org.macports.bind9/org.macports.bind9.plist
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
	tail)
		sudo tail -n 500 -f /opt/local/var/log/named/debug.log
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" >&2
		exit 1
	;;
esac

exit 0

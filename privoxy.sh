#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		sudo chown -R privoxy:privoxy /opt/local/var/log/privoxy /opt/local/etc/privoxy 
		sudo launchctl load -w /opt/local/etc/LaunchDaemons/org.macports.Privoxy/org.macports.Privoxy.plist 
	;;
	stop)
		echo "stopping"
		sudo launchctl unload -w /opt/local/etc/LaunchDaemons/org.macports.Privoxy/org.macports.Privoxy.plist
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
	tail)
		sudo tail -n 500 -f /opt/local/var/log/privoxy/logfile 
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" >&2
		exit 1
	;;
esac

exit 0

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


start() {
	echo "starting"
	sudo chown -R squid:squid /opt/local/etc/squid /opt/local/var/squid /opt/local/var/run/squid
	sudo launchctl load -w /Library/LaunchDaemons/org.macports.Squid.plist
}

stop() {
	echo "stopping"
	sudo launchctl unload -w /Library/LaunchDaemons/org.macports.Squid.plist || true
	sleep 2
	ps ax | grep '(squid-1) -s' | grep -v grep | awk '{ print $1 }' | sudo xargs --no-run-if-empty kill -9 || true
	ps ax | grep 'squid -s'     | grep -v grep | awk '{ print $1 }' | sudo xargs --no-run-if-empty kill -9 || true
}

case "$1" in
	start)
		start
	;;
	stop)
		stop
	;;
	restart)
		stop
		sleep 1
		start
	;;
	tail)
		sudo tail -n 500 -f /opt/local/var/squid/logs/*.log
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" >&2
		exit 1
	;;
esac

exit 0

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		sudo chown -R privoxy:privoxy /opt/local/var/log/privoxy /opt/local/etc/privoxy 
		sudo chown -R squid:squid /opt/local/etc/squid /opt/local/var/squid /opt/local/var/run/squid
		sudo launchctl load -w /opt/local/etc/LaunchDaemons/org.macports.Privoxy/org.macports.Privoxy.plist 
		sudo launchctl load -w /Library/LaunchDaemons/org.macports.Squid.plist
	;;
	stop)
		echo "stopping"
		sudo launchctl unload -w /opt/local/etc/LaunchDaemons/org.macports.Privoxy/org.macports.Privoxy.plist
		sudo launchctl unload -w /Library/LaunchDaemons/org.macports.Squid.plist 
		sleep 2
		sudo kill -9 `ps ax | grep '(squid)' | grep -v grep | awk '{ print $1 }'`
	;;
	restart)
		$0 stop
		sleep 1
		$0 start
	;;
	tailsquid)
		sudo tail -n 500 -f /opt/local/var/squid/logs/*.log
	;;
	tailprivoxy)
		sudo tail -n 500 -f /opt/local/var/log/privoxy/logfile 
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" >&2
		exit 1
	;;
esac

exit 0

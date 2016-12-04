#!/bin/sh

case "$1" in
       	start)
       		echo "starting"
       		sudo launchctl load -w /opt/local/etc/LaunchDaemons/org.macports.postgresql96-server/org.macports.postgresql96-server.plist
       	;;
       	stop)
       		echo "stopping"
       		sudo launchctl unload -w /opt/local/etc/LaunchDaemons/org.macports.postgresql96-server/org.macports.postgresql96-server.plist
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

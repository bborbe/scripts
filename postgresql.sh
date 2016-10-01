#!/bin/sh

case "$1" in
       	start)
       		echo "starting"
       		sudo launchctl load -w /Library/LaunchDaemons/org.macports.postgresql94-server.plist
       	;;
       	stop)
       		echo "stopping"
       		sudo launchctl unload -w /Library/LaunchDaemons/org.macports.postgresql94-server.plist
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
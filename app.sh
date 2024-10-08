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
		open -a Alfred\ 5 -g
		open -a KeepingYouAwake -g
		open -a Calendar -g
		open -a Enpass -g
		open -a Google\ Chrome -g
		open -a iTerm -g
		open -a Tabby -g
		open -a Hyper -g
		open -a Music -g
		open -a Mail -g
		open -a NetNewsWire -g
		open -a OmniFocus -g
		open -a Telegram -g
		open -a Viscosity -g
		open /Library/PreferencePanes/HyperDock.prefpane/Contents/Resources/HyperDock\ Helper.app -g		
	;;
	stop)
		echo "stopping"
		killall -9 java
		kill `ps -U bborbe | grep -v 'kill ' | grep -v 'home.sh' | awk '{ print $1 };'`
		kill -9 `ps -U bborbe | grep -v 'kill ' | grep -v 'home.sh' | awk '{ print $1 };'`
	;;
	*)
		help
	;;
esac

exit 0

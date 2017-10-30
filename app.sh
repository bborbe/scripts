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
		open -a 1Password\ 6 -g
		open -a Alfred\ 3 -g
		open -a Caffeine -g
		open -a Calendar -g
		#open -a Discord -g
		#open -a Emacs -g
		open -a FastScripts -g
		#open -a Firefox -g
		open -a Google\ Chrome -g
		open -a iTerm -g
		open -a iTunes -g
		open -a Mail -g
		open -a NetNewsWire -g
		open -a OmniFocus -g
		open -a Salute -g
		open -a Telegram -g
		#open -a Wire -g
		open -a Terminal -g
		#open -a TextEdit -g
		#open -a Thunderbird -g
		#open -a Twitter -g
		open -a Viscosity -g
		open /Library/PreferencePanes/HyperDock.prefpane/Contents/Resources/HyperDock\ Helper.app -g		
		open ~/Documents/notes.txt
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

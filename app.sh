#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

case "$1" in
	start)
		echo "starting"
		open -a Alfred -g
		open -a Viscosity -g
		open -a FastScripts -g
		open -a Caffeine -g
		open /Users/bborbe/Library/PreferencePanes/HyperDock.prefpane/Contents/Resources/HyperDock\ Helper.app -g
		open -a Google\ Chrome -g
		open -a Mail -g
		open -a iTunes -g
		open -a NetNewsWire -g
		open -a Calendar -g
		open -a iTerm -g
		open -a Terminal -g
		open -a TextEdit -g
		open -a 1Password\ 6
		open -a OmniFocus -g
		open -a Telegram -g
		open -a Twitter -g
#		open -a Mattermost -g
		open -a Emacs -g
		open -a Firefox -g
#		open -a Skype -g 
	;;
	stop)
		echo "stopping"
		killall -9 java
		kill `ps -U bborbe | grep -v 'kill ' | grep -v 'home.sh' | awk '{ print $1 };'`
		kill -9 `ps -U bborbe | grep -v 'kill ' | grep -v 'home.sh' | awk '{ print $1 };'`
	;;
	*)
		echo "Usage: $0 {start|stop}" >&2
		exit 1
	;;
esac

exit 0

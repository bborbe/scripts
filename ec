#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

which osascript > /dev/null 2>&1 && osascript -e 'tell application "Emacs" to activate'
emacsclient -n -c "$@"

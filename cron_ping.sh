#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

/opt/local/bin/perl ~/Documents/workspaces/scripts/ping.pl >> ~/Library/Logs/ping.log 2>&1

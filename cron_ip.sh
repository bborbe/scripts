#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

/Users/bborbe/Documents/workspaces/go/bin/ip-client --url https://ip.benjamin-borbe.de >> ~/Library/Logs/ip.log 2>&1

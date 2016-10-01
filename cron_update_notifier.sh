#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

/Users/bborbe/Documents/workspaces/go/bin/update_notifier_cron -loglevel=INFO -smtp-password=wYog90aOAdUBQinz >> ~/Library/Logs/update_notifier.log 2>&1

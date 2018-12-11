#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH=/opt/phantomjs/bin:$PATH

/Users/bborbe/Documents/workspaces/go/bin/monitoring-cron \
-logtostderr \
-v=2 \
-concurrent 1 \
-smtp-host=mail.benjamin-borbe.de \
-smtp-port=25 \
-config=/Users/bborbe/Documents/workspaces/kubernetes/monitoring/local/config.xml \
>> ~/Library/Logs/monitoring.log 2>&1


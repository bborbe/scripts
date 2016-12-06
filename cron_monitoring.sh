#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export PATH=/opt/phantomjs/bin:$PATH

/Users/bborbe/Documents/workspaces/go/bin/monitoring_cron \
-logtostderr \
-v=2 \
-concurrent 1 \
-smtp-host=iredmail.mailfolder.org \
-smtp-port=465 \
-smtp-password=wYog90aOAdUBQinz \
-smtp-tls=true \
-smtp-tls-skip-verify=true \
-config=/Users/bborbe/Documents/workspaces/kubernetes/monitoring/local/config.xml \
>> ~/Library/Logs/monitoring.log 2>&1

exit 0

/Users/bborbe/Documents/workspaces/go/bin/monitoring_cron \
-logtostderr \
-v=2 \
-concurrent 1 \
-smtp-password=wYog90aOAdUBQinz \
-config=/Users/bborbe/Documents/workspaces/monitoring_configuration/playground.xml \
>> ~/Library/Logs/monitoring.log 2>&1

/Users/bborbe/Documents/workspaces/go/bin/monitoring_cron \
-logtostderr \
-v=2 \
-concurrent 1 \
-smtp-password=wYog90aOAdUBQinz \
-config=/Users/bborbe/Documents/workspaces/monitoring_configuration/codeyard-template.xml \
>> ~/Library/Logs/monitoring.log 2>&1


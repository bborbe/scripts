#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

/sbin/iptables-restore < /etc/iptables.rules

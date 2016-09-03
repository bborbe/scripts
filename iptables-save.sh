#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

/sbin/iptables-save -c > /etc/iptables.rules

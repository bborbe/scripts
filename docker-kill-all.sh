#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker ps -a -q -f status=running | xargs --no-run-if-empty docker kill


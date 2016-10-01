#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker kill $(docker ps -a -q -f status=running)


#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker exec -i -t $(docker ps -a -q -f status=running) /bin/bash


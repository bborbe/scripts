#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker rm -v $(docker ps -a -q -f status=exited)
docker rmi $(docker images -f "dangling=true" -q)


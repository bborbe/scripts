#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker rm -v $(docker ps -a -q)
docker rmi $(docker images -q)

#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker ps -a -q -f status=exited | xargs --no-run-if-empty docker rm -v
docker images -f "dangling=true" -q | xargs --no-run-if-empty docker rmi
docker system prune -af
docker volume prune -f

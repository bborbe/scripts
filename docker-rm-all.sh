#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker ps -a -q | xargs --no-run-if-empty docker rm 


#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

SOURCE="$1"
TARGET="$2"

echo "clone ${SOURCE} to ${TARGET}"

gcloud docker --server=eu.gcr.io -- pull ${SOURCE} || true
sleep 2
docker tag `docker images ${SOURCE} -q` ${TARGET}
gcloud docker --server=eu.gcr.io -- push ${TARGET}

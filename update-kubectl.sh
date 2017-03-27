#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

taglist='https://gcr.io/v2/google_containers/hyperkube-amd64/tags/list'
latest=$(curl -s ${taglist} | jq -r '.tags|.[]' | grep -v beta | grep -v alpha | grep -v rc | sort | tail -n 1)
echo "latest version ${latest}"
curl -O https://storage.googleapis.com/kubernetes-release/release/${latest}/bin/darwin/amd64/kubectl
chmod a+x kubectl

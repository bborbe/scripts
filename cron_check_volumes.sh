#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ls -ld /Volumes/*/* > /dev/null

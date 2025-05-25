#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

wol 00:e0:4c:00:65:66
wol bc:5f:f4:79:ec:59


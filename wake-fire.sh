#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

etherwake bc:5f:f4:79:ec:59
wakeonlan bc:5f:f4:79:ec:59

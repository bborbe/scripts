#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo port uninstall `sudo port installed | grep -v ' (active)'`
sudo port clean all

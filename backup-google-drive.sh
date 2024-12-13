#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

rsync -av --progress \
/Users/bborbe/My\ Drive\ \(benjamin.borbe@gmail.com\) \
/Users/bborbe/My\ Drive\ \(borbe.capital@gmail.com\) \
bborbe@fire.hm.benjamin-borbe.de:/home/bborbe/Backups/Google\ Drive/
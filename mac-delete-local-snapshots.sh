#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

for name in $(tmutil listlocalsnapshotdates | grep "-"); do
    sudo tmutil deletelocalsnapshots $name;
done


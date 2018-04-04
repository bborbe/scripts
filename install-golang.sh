#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

GO_VERSION=${GO_VERSION:-"1.10.1"}
GO_TARGET="/opt/go${GO_VERSION}"
GO_ROOT="/opt/go"

GO_ARCH=$(uname -s)
# convert GO_ARCH to lowercase
GO_ARCH=${GO_ARCH,,}
echo "install Go ${GO_VERSION} ${GO_ARCH} to ${GO_TARGET}. please enter password for sudo."

sudo mkdir -p "${GO_TARGET}"
curl -Ls "https://dl.google.com/go/go${GO_VERSION}.${GO_ARCH}-amd64.tar.gz" | sudo tar -xz --directory "${GO_TARGET}" --strip-components=1 --no-same-owner 
sudo ln --symbolic --force "${GO_TARGET}" "${GO_ROOT}"

echo 'add to ~/.bash_profile'
echo 'GOPATH="$HOME/go"'
echo "GOROOT=\"${GO_ROOT}\""
echo 'PATH="$PATH:$GOROOT/bin:$GOPATH/bin"'

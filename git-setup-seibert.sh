#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "Setting up git config for seibert..."

git config user.signingkey 316D75C06123D41D
git config commit.gpgsign true
git config user.email "benjamin.borbe@seibert.group"

echo "git config for seibert applied:"
echo "  Signing key: $(git config user.signingkey)"
echo "  GPG signing: $(git config commit.gpgsign)"
echo "  Email: $(git config user.email)"

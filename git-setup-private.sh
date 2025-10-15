#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo "Setting up git config for private..."

git config user.signingkey 21260C2C6244AC77
git config commit.gpgsign true
git config user.email "benjamin.borbe@gmail.com"

echo "Work git config for private applied:"
echo "  Signing key: $(git config user.signingkey)"
echo "  GPG signing: $(git config commit.gpgsign)"
echo "  Email: $(git config user.email)"

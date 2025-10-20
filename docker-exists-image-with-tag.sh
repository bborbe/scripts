#!/usr/bin/env bash
#
# Check if a Docker image with a specific tag exists in a registry.
#
# Usage:
#   REGISTRY=docker.io USER=myuser PASS=mypass IMAGE=library/ubuntu TAG=22.04 ./docker-exists-image-with-tag.sh
#
# Required environment variables:
#   REGISTRY - Docker registry hostname (e.g., docker.io, ghcr.io)
#   USER     - Registry username
#   PASS     - Registry password or token
#   IMAGE    - Image name (e.g., library/ubuntu, myorg/myimage)
#   TAG      - Image tag to check (e.g., latest, v1.0.0)
#
# Credentials:
#   If USER is set but PASS is empty, the script attempts to read credentials
#   from ~/.docker/config.json for the specified REGISTRY.
#
# Exit codes:
#   0 - Image tag found
#   1 - Image tag not found or error occurred
#
# Requirements:
#   - jq (JSON processor)
#   - curl

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

if ! jq --help >/dev/null 2>&1; then
    echo "jq missing"
    exit 1
fi

REGISTRY=${REGISTRY:-""}
USER=${USER:-""}
PASS=${PASS:-""}
IMAGE=${IMAGE:-""}
TAG=${TAG:-""}

if ! [ -z "$USER" ] && [ -z "$PASS" ]; then
    string=$(cat ~/.docker/config.json | jq -r '.auths' | jq -r ".\"${REGISTRY}\"" | jq -r '.auth' | base64 -d)
    IFS=':' read -ra array <<< "$string"
    USER=${array[0]}
    PASS=${array[1]}
fi
if [ -z "$USER" ]; then
    echo "USER missing"
    exit 1
fi
if [ -z "$PASS" ]; then
    echo "PASS missing"
    exit 1
fi
if [ -z "$IMAGE" ]; then
    echo "IMAGE missing"
    exit 1
fi
if [ -z "$TAG" ]; then
    echo "TAG missing"
    exit 1
fi

EXISTS=false
RESPONSE=$(curl -s -u "${USER}:${PASS}" "https://${REGISTRY}/v2/${IMAGE}/tags/list")
TAGS=$(echo "$RESPONSE" | jq -r '.tags|.[]')
while IFS= read -r i; do
    if [ "$i" == "$TAG" ]; then
	EXISTS=true
    fi
done <<< "$TAGS"

if $EXISTS; then
    echo "found ${IMAGE}:${TAG}"
    exit 0
else
    echo "not found ${IMAGE}:${TAG}"
    exit 1
fi

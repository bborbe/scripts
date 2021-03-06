#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

jq --help >/dev/null 2>&1 || echo "jq missing"

REGISTRY=${REGISTRY:-""}
if [ -z $REGISTRY ]; then
    echo "REGISTRY missing"
    exit 1
fi

IMAGE=${IMAGE:-""}
if [ -z $IMAGE ]; then
    echo "IMAGE missing"
    exit 1
fi

TAG=${TAG:-""}
if [ -z $TAG ]; then
    echo "TAG missing"
    exit 1
fi

USER=${USER:-""}
PASS=${PASS:-""}
if ! [ -z $USER ] && [ -z $PASS ]; then
    string=$(cat ~/.docker/config.json | jq -r '.auths' | jq -r ".\"${REGISTRY}\"" | jq -r '.auth' | base64 -d)
    array=(${string//:/ })
    USER=${array[0]}
    PASS=${array[1]}
fi
if [ -z $USER ]; then
    echo "USER missing"
    exit 1
fi
if [ -z $PASS ]; then
    echo "PASS missing"
    exit 1
fi

EXISTS=false
RESPONSE=$(curl -s -u "${USER}:${PASS}" https://${REGISTRY}/v2/${IMAGE}/tags/list)
TAGS=$(echo $RESPONSE | jq -r '.tags|.[]')
for i in $TAGS; do
    if [ "$i" == "$TAG" ]; then
	EXISTS=true
    fi
done

if $EXISTS; then
    echo "found ${IMAGE}:${TAG}"
    exit 0
else
    echo "not found ${IMAGE}:${TAG}"
    exit 1
fi

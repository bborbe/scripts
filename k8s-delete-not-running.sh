#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

for ns in $(kubectl get pods --all-namespaces | grep -v NAME | grep -v "Running" | awk '{print $1}' | sort | uniq); do
echo "delete pods in namespace $ns";
kubectl -n "$ns" get pods | grep -v NAME | grep -v "Running" | awk '{print $1}' | xargs --no-run-if-empty kubectl -n "$ns" delete pod;
done

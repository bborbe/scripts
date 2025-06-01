#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

for ns in $(kubectl get pods --all-namespaces | grep -E "NotReady|Unknown|InvalidImageName|CrashLoopBackOff|Evicted|OOMKilled|Error|ImagePullBackOff" | awk '{print $1}' | sort | uniq); do
echo "delete pods in namespace $ns";
kubectl -n "$ns" get pods | grep -E "NotReady|Unknown|InvalidImageName|CrashLoopBackOff|Evicted|OOMKilled|Error|ImagePullBackOff" | awk '{print $1}' | xargs --no-run-if-empty kubectl -n "$ns" delete pod  --grace-period=0 --force;
done

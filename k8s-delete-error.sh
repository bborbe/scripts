#!/bin/bash

kubectl get pods --all-namespaces -a | grep -E "CrashLoopBackOff|Evicted|OOMKilled|Error|ImagePullBackOff" | awk '{print $2 " -n " $1}' | xargs --no-run-if-empty kubectl delete pod

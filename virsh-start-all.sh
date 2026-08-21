#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

# VMs deliberately NOT started by this script -- i.e. not part of the set that
# normally runs. Start them by hand with `virsh start <vm>` when needed.
#   nuke-boss, nuke-workspace       -- started on demand
#   nuke-k3s-prod, nuke-k3s-dev     -- old single-node clusters, destroyed 2026-07-20
#   nuke-k3s-dev-0                  -- DRAINED AND SHUT DOWN 2026-08-20 after the whole
#                                      dev stack (trading + agent platform) moved to the
#                                      nuke-dev cluster. Still DEFINED on purpose: its
#                                      disk holds ~460 GB of retained source PVCs, the
#                                      fallback for every migration batch. Do not
#                                      undefine or remove the LV until prod has migrated
#                                      too and the fallback is genuinely not needed.
#   nuke-k3s-agent-0                -- DRAINED AND SHUT DOWN 2026-08-21, freeing 32 GiB
#                                      back to the host. It held quant cluster infra
#                                      (k8s-pod-status across 8 namespaces,
#                                      k8s-secret-syncer, keel-prod, alert-controller,
#                                      karma), all of which was re-pinned from
#                                      node_type=agent to node_type In [prod, kafka] so
#                                      it also survives the coming prod-0 shutdown.
#                                      Still DEFINED on purpose, same reasoning as
#                                      dev-0: its disk holds 8 local-path PVs of agent
#                                      workspace data (agent-claude, agent-pi,
#                                      agent-hypothesis, agent-trade-analysis,
#                                      agent-sentry-issue-analyzer). Nothing mounts them
#                                      -- nuke-prod has its own copies -- but keep the LV
#                                      until the migration is signed off.
#   nuke-k3s-prod-0                 -- DRAINED AND SHUT DOWN 2026-08-21, freeing ~32 GiB
#                                      back to the host. quant's last large node. Its 17
#                                      running pods relocated cleanly: 12 carried
#                                      node_type In [prod, kafka] and moved to the kafka
#                                      nodes, 2 were DaemonSets, and the 2 unconstrained
#                                      strimzi-topic-controllers landed on master-1
#                                      (untainted) -- those two still have NO node
#                                      affinity and should be pinned to node_type=kafka.
#                                      Prerequisites merged the same day: quant#183
#                                      (sentry-proxy -> [prod, kafka]) and trading#241
#                                      (strimzi entity operator -> [kafka]).
#                                      Still DEFINED on purpose, same reasoning as dev-0
#                                      and agent-0: its disk holds 391 local-path PVs
#                                      (~432 GiB, all Bound) of retained prod trading
#                                      data -- candle handlers, signal finders, mt5-vnc,
#                                      agent-task-controller. Do not undefine or remove
#                                      the LV until the PVC migration is signed off.
EXCLUDE=(nuke-boss nuke-workspace nuke-k3s-prod nuke-k3s-dev nuke-k3s-dev-0 nuke-k3s-agent-0 nuke-k3s-prod-0)

for vm in $(virsh list --state-shutoff --name); do
  skip=0
  for ex in "${EXCLUDE[@]}"; do
    if [[ "$vm" == "$ex" ]]; then
      skip=1
      break
    fi
  done
  if [[ $skip -eq 1 ]]; then
    echo "skip $vm (excluded)"
    continue
  fi
  virsh start "$vm"
done

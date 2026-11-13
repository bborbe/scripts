#!/usr/bin/env bash
#
# nuke-k3s-quiesce.sh -- the local twin of remote-k3s-shutdown-nuke.sh.
#
# Same job (stop K3s on every nuke guest, leave the VMs running) and the same
# per-host command, but run ON the nuke host instead of from the workstation.
# Needs working LAN + DNS: every guest is reached by its
# <domain>.hm.benjamin-borbe.de name, so this is the wrong tool the moment DNS
# is gone -- use nuke-power-off.sh (virsh, no network) in that case.
#
#   ssh nuke.hm.benjamin-borbe.de
#   /root/scripts/nuke-k3s-quiesce.sh --dry-run
#   /root/scripts/nuke-k3s-quiesce.sh
#
# PRECONDITION: an SSH key the guests accept, unlocked, for the user running
# this. The guests' authorized_keys hold bborbe's personal key, and nuke's copy
# of that key is PASSPHRASE-PROTECTED with no agent running -- so as of
# 2026-11-13 ssh from nuke fails with "Permission denied (publickey)" after
# "Server accepts key". The preflight below reports exactly that instead of
# letting the run look like a K3s problem. Fix by installing a dedicated
# passphrase-free key on nuke and authorising its .pub on the guests, or by
# running this with a loaded agent.
#
# Differences from remote-k3s-shutdown-nuke.sh, both deliberate:
#   - the node list comes from `virsh list --state-running`, not a hardcoded
#     list. The hardcoded list went stale twice (2026-08-23: decommissioned
#     nodes left in it aborted the run under `set -o errexit` before the kafka
#     and master blocks, leaving exactly the torn Kafka/etcd state this job
#     exists to prevent). Deriving the list cannot drift.
#   - a failing host no longer aborts the run. Every host is attempted, and the
#     summary at the end names the ones that failed.

set -o nounset
set -o pipefail

DOMAIN=hm.benjamin-borbe.de
SSH_USER="${SSH_USER:-bborbe}"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new)
REMOTE_CMD='sudo systemctl stop k3s; sudo systemctl stop k3s-agent; sudo /usr/local/bin/k3s-killall.sh; sudo mkdir -p /var/lib/rancher/k3s/storage; sudo mount /var/lib/rancher/k3s/storage; echo done'
DRY_RUN=0
ASSUME_YES=0

usage() {
  cat <<'EOF'
usage: nuke-k3s-quiesce.sh [--dry-run] [--yes]

Stops k3s / k3s-agent on every running nuke-k3s-* guest and leaves the VMs
running. Run ON the nuke host. Needs LAN + DNS and an unlocked SSH key the
guests accept.

  --dry-run   resolve, order and preflight the hosts, change nothing
  --yes       do not ask for confirmation
EOF
}

log() { printf '%s\n' "$*"; }

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --yes) ASSUME_YES=1 ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        printf "ERROR: unknown argument '%s'\n" "$1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

require_nuke() {
  local host
  host="$(hostname -s)"
  case "$host" in
    nuke*) : ;;
    *)
      log "ERROR: this is '$host' -- run this on the nuke host, or use remote-k3s-shutdown-nuke.sh from the workstation"
      exit 1
      ;;
  esac
  if ! command -v virsh >/dev/null 2>&1; then
    log "ERROR: virsh not found -- not a libvirt host?"
    exit 1
  fi
}

running_k3s_nodes() {
  virsh list --state-running --name | sed '/^[[:space:]]*$/d' | grep -E '^nuke-k3s-' || true
}

# workers first, kafka second, masters last -- the order the reboot runbook
# uses, so the control plane goes down after the workloads it schedules.
ordered_nodes() {
  local nodes
  nodes="$(running_k3s_nodes)"
  {
    grep -E 'worker' <<<"$nodes" || true
    grep -E 'kafka' <<<"$nodes" || true
    grep -E 'master' <<<"$nodes" || true
    grep -vE 'worker|kafka|master' <<<"$nodes" || true
  } | sed '/^[[:space:]]*$/d'
}

preflight() {
  local node fqdn ip failed=0
  local -a nodes
  mapfile -t nodes < <(ordered_nodes)
  if [ "${#nodes[@]}" -eq 0 ]; then
    log "ERROR: no running nuke-k3s-* guest found in virsh -- nothing to quiesce"
    exit 1
  fi
  log "nodes (${#nodes[@]}):"
  for node in "${nodes[@]}"; do
    fqdn="$node.$DOMAIN"
    ip="$(getent hosts "$fqdn" | awk '{print $1; exit}')"
    if [ -z "$ip" ]; then
      log "  $node -- DNS FAILED for $fqdn"
      failed=$((failed + 1))
      continue
    fi
    if ! ssh "${SSH_OPTS[@]}" "$SSH_USER@$fqdn" true >/dev/null 2>&1; then
      log "  $node ($ip) -- SSH FAILED (key not accepted or locked)"
      failed=$((failed + 1))
      continue
    fi
    log "  $node ($ip) -- ok"
  done
  if [ "$failed" -ne 0 ]; then
    log ""
    log "ERROR: $failed of ${#nodes[@]} node(s) unreachable -- fix those first."
    log "       DNS failure  -> the LAN/DNS is down; use nuke-power-off.sh instead."
    log "       SSH failure  -> nuke has no unlocked key the guests accept."
    exit 1
  fi
}

confirm() {
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  local answer
  printf 'Stop K3s on all running nuke guests (VMs stay up)? [yes/NO] ' >/dev/tty
  read -r answer </dev/tty
  case "$answer" in
    yes | YES | y | Y) : ;;
    *)
      log "aborted by operator -- nothing was changed"
      exit 2
      ;;
  esac
}

quiesce_node() {
  local node="$1" fqdn="$node.$DOMAIN" out
  if [ "$DRY_RUN" -eq 1 ]; then
    log "[DRY-RUN] $node"
    return 0
  fi
  if out="$(ssh "${SSH_OPTS[@]}" "$SSH_USER@$fqdn" "$REMOTE_CMD" 2>&1)"; then
    log "[SUCCESS] $node"
    return 0
  fi
  log "[FAILED]  $node -- ${out##*$'\n'}"
  return 1
}

main() {
  parse_args "$@"
  require_nuke
  log "=== nuke-k3s-quiesce start (dry-run=$DRY_RUN) ==="
  preflight
  confirm
  local node failed=0 total=0
  while IFS= read -r node; do
    [ -z "$node" ] && continue
    total=$((total + 1))
    quiesce_node "$node" || failed=$((failed + 1))
  done < <(ordered_nodes)
  log ""
  log "summary: $((total - failed))/$total quiesced, $failed failed"
  if [ "$failed" -ne 0 ]; then
    log "re-run after fixing the failed host(s) -- the command is idempotent"
    exit 1
  fi
}

main "$@"

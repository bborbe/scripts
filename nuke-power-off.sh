#!/usr/bin/env bash
#
# nuke-power-off.sh -- graceful power-off of the nuke KVM host on a power outage.
#
# Run ON the nuke host, as root, while the UPS is still carrying the load:
#
#   sudo -s
#   cd /root/scripts && git pull
#   ./nuke-power-off.sh --dry-run     # show the plan, change nothing
#   ./nuke-power-off.sh               # confirm, shut guests down, power off host
#
# Short runtime left on the UPS (get-it-down-fast combination):
#
#   ./nuke-power-off.sh --yes --timeout 120 --force
#
# This is the manual sequence -- `virsh-shutdown-all.sh` then `shutdown -h now` --
# with three things added: it waits for the guests before powering the host off,
# it syncs the RAID array first, and it logs to /var/log/nuke-power-off.log so
# the run can be read after the host comes back.
#
# No network is needed. `virsh shutdown` delivers an ACPI power-button event over
# the QEMU unix socket, the guest's own systemd then stops K3s and Kafka inside
# the VM, and `systemctl poweroff` is local. A dead LAN or a dead uplink changes
# nothing; only `remote-k3s-shutdown-nuke.sh` (pssh over SSH) needs the network,
# which is why it is the wrong tool here.
#
# Guests are waited for before the host goes down so libvirt-guests has nothing
# left to suspend: ON_SHUTDOWN is unset in /etc/default/libvirt-guests, so a
# still-running guest would otherwise be suspended to disk rather than stopped.
#
# Exit codes: 0 powered off, 1 preflight failed, 2 aborted by operator.

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

LOG_FILE="${LOG_FILE:-/var/log/nuke-power-off.log}"
GUEST_TIMEOUT="${GUEST_TIMEOUT:-300}"
ASSUME_YES=0
DRY_RUN=0
FORCE=0

usage() {
  cat <<'EOF'
usage: nuke-power-off.sh [--dry-run] [--yes] [--force] [--timeout SECONDS]

  --dry-run        show the plan, change nothing
  --yes            do not ask for confirmation
  --force          virsh destroy guests still running after --timeout
  --timeout N      seconds to wait for guests to shut down (default 300)

Run as root on the nuke host. Guests are shut down over ACPI first, so their
systemd stops K3s and Kafka cleanly; the host powers off last.
EOF
}

log() {
  local line
  line="$(date '+%F %T') $*"
  printf '%s\n' "$line"
  printf '%s\n' "$line" >>"$LOG_FILE"
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --yes) ASSUME_YES=1 ;;
      --force) FORCE=1 ;;
      --timeout)
        shift
        if [ $# -eq 0 ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
          printf 'ERROR: --timeout needs a number of seconds\n' >&2
          exit 1
        fi
        GUEST_TIMEOUT="$1"
        ;;
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

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    printf 'ERROR: run as root -- sudo -s, then re-run\n' >&2
    exit 1
  fi
}

require_nuke() {
  local host
  host="$(hostname -s)"
  case "$host" in
    nuke*) : ;;
    *)
      log "ERROR: this is '$host', not the nuke host -- refusing to power it off"
      exit 1
      ;;
  esac
  if ! command -v virsh >/dev/null 2>&1; then
    log "ERROR: virsh not found -- not a libvirt host?"
    exit 1
  fi
}

running_guests() {
  virsh list --state-running --name | sed '/^[[:space:]]*$/d'
}

preflight() {
  local guest
  log "host:   $(hostname -s) ($(uptime -p 2>/dev/null || echo 'uptime unknown'))"
  log "log:    $LOG_FILE"
  log "guests running:"
  while IFS= read -r guest; do
    [ -z "$guest" ] && continue
    log "  $guest"
  done < <(running_guests)
}

confirm() {
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  local count answer
  count="$(running_guests | wc -l | tr -d ' ')"
  printf 'Shut down %s guest(s) and power off %s? [yes/NO] ' \
    "$count" "$(hostname -s)" >/dev/tty
  read -r answer </dev/tty
  case "$answer" in
    yes | YES | y | Y) : ;;
    *)
      log "aborted by operator -- nothing was changed"
      exit 2
      ;;
  esac
}

shutdown_guests() {
  local guest
  while IFS= read -r guest; do
    [ -z "$guest" ] && continue
    if [ "$DRY_RUN" -eq 1 ]; then
      log "dry-run: would shut down guest $guest"
      continue
    fi
    log "shutdown guest $guest"
    virsh shutdown "$guest" || log "WARN: virsh shutdown $guest failed"
  done < <(running_guests)
}

wait_for_guests() {
  local deadline next_report running count guest
  deadline=$((SECONDS + GUEST_TIMEOUT))
  next_report=$((SECONDS + 30))
  while :; do
    running="$(running_guests)"
    if [ -z "$running" ]; then
      log "all guests shut down"
      return 0
    fi
    count="$(printf '%s\n' "$running" | wc -l | tr -d ' ')"
    if [ "$SECONDS" -ge "$deadline" ]; then
      log "TIMEOUT: $count guest(s) still running after ${GUEST_TIMEOUT}s"
      while IFS= read -r guest; do
        log "  still running: $guest"
      done <<<"$running"
      return 1
    fi
    if [ "$SECONDS" -ge "$next_report" ]; then
      log "$count guest(s) still shutting down, $((deadline - SECONDS))s left"
      next_report=$((SECONDS + 30))
    fi
    sleep 5
  done
}

destroy_stragglers() {
  local guest
  while IFS= read -r guest; do
    [ -z "$guest" ] && continue
    log "destroy guest $guest (power-cut equivalent)"
    virsh destroy "$guest" || log "WARN: virsh destroy $guest failed"
  done < <(running_guests)
}

power_off() {
  log "sync"
  sync
  log "powering off $(hostname -s)"
  systemctl poweroff
}

main() {
  parse_args "$@"
  require_root
  require_nuke
  log "=== nuke-power-off start (dry-run=${DRY_RUN} force=${FORCE} timeout=${GUEST_TIMEOUT}s) ==="
  preflight
  confirm
  shutdown_guests
  if [ "$DRY_RUN" -eq 1 ]; then
    log "dry-run: stopping before the shutdown wait"
    exit 0
  fi
  if ! wait_for_guests; then
    if [ "$FORCE" -eq 1 ]; then
      destroy_stragglers
    else
      log "WARN: powering off with guests still running -- the host shutdown cuts them; use --force to destroy them first"
    fi
  fi
  power_off
}

main "$@"

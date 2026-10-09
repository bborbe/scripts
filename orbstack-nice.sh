#!/usr/bin/env bash
# orbstack-nice.sh - keep the OrbStack VM helper at nice 10
#
# Problem: OrbStack exposes no scheduling-priority setting - `orb config show`
# lists only sizing/network/k8s/app keys - so its VM helper runs at nice 0 and
# competes with foreground work until the Mac feels slow. A manual `renice 10`
# fixes it, but the value is lost on every OrbStack restart and every reboot.
#
# This script is run by a LaunchAgent (RunAtLoad + StartInterval) to re-apply
# the renice. It is idempotent - re-running it is always safe.
#
# Usage: orbstack-nice.sh
#
# Env:
#   ORBSTACK_NICE        nice value to apply (default 10)
#   ORBSTACK_WAIT_SECS   seconds to wait for the helper (default 60)

set -o errexit
set -o nounset
set -o pipefail

NICE_VALUE="${ORBSTACK_NICE:-10}"
WAIT_SECS="${ORBSTACK_WAIT_SECS:-60}"
PATTERN="OrbStack Helper"

log() {
	echo "$(date -u +%FT%TZ) $*"
}

# Wait for the helper, but only for WAIT_SECS. RunAtLoad plus a 60s
# StartInterval would otherwise stack one hung instance per minute whenever
# OrbStack is not running.
deadline=$((SECONDS + WAIT_SECS))
pids=""
while :; do
	pids="$(pgrep -f "$PATTERN" || true)"
	if [ -n "$pids" ]; then
		break
	fi
	if [ "$SECONDS" -ge "$deadline" ]; then
		log "no '$PATTERN' process after ${WAIT_SECS}s - OrbStack not running, exiting"
		exit 0
	fi
	sleep 2
done

for pid in $pids; do
	# `|| true` is load-bearing: `ps` exits non-zero for a pid that has gone,
	# and `set -o pipefail` turns that into a non-zero command substitution,
	# which `set -o errexit` would abort on before the -z check could run.
	current="$(ps -o nice= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
	if [ -z "$current" ]; then
		log "pid $pid disappeared before renice - skipping"
		continue
	fi
	if [ "$current" = "$NICE_VALUE" ]; then
		log "reniced $pid -> $current (already set)"
		continue
	fi
	renice "$NICE_VALUE" -p "$pid" >/dev/null
	applied="$(ps -o nice= -p "$pid" 2>/dev/null | tr -d ' ' || true)"
	log "reniced $pid -> ${applied:-gone}"
done

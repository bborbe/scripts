#!/usr/bin/env bash
# mac-watch.sh — Continuously sample macOS memory, file-descriptor, and Docker state.
#
# Logs one line every 30s with:
#   - vm_stat memory breakdown (free, active, inactive, wired, compressor)
#   - system-wide open-file count vs kernel cap (kern.num_files / kern.maxfiles)
#   - Docker activity (running containers, active builds, VM RSS + FDs)
#   - top 3 processes by RSS (every sample) and top 3 FD-holders (every ~5 min)
#
# Useful for catching memory-pressure / FD-leak events leading up to kernel panics or
# JetsamEvents. Designed to be lightweight (one vm_stat + one sysctl + one lsof every 5 min).
#
# Usage:
#   ./mac-watch.sh                 # foreground
#   nohup ./mac-watch.sh &         # background, survives terminal exit
#   tail -f /tmp/mac-watch.log     # follow output
#   pkill -f mac-watch.sh          # stop
#
# Output: /tmp/mac-watch.log (rotates at ~10 MB to /tmp/mac-watch.log.1)
#
# Tested on Apple Silicon (16K page size). The page-size detection works on Intel too.

set -u

LOG=${MAC_WATCH_LOG:-/tmp/mac-watch.log}
INTERVAL=${MAC_WATCH_INTERVAL:-30}
ROTATE_BYTES=${MAC_WATCH_ROTATE_BYTES:-10485760}

rotate() {
  if [ -f "$LOG" ] && [ "$(stat -f%z "$LOG" 2>/dev/null || echo 0)" -gt "$ROTATE_BYTES" ]; then
    mv "$LOG" "$LOG.1"
  fi
}

while :; do
  rotate
  TS=$(date '+%Y-%m-%d %H:%M:%S')

  # Memory: vm_stat reports pages; multiply by page size from the header.
  read -r PAGESIZE FREE ACTIVE INACTIVE WIRED COMPRESSED <<<"$(vm_stat | awk '
    /page size of/           { gsub("\\.",""); ps=$8 }
    /Pages free/             { gsub("\\.",""); free=$3 }
    /Pages active/           { gsub("\\.",""); active=$3 }
    /Pages inactive/         { gsub("\\.",""); inactive=$3 }
    /Pages wired/            { gsub("\\.",""); wired=$4 }
    /occupied by compressor/ { gsub("\\.",""); comp=$5 }
    END { printf "%d %d %d %d %d %d", ps, free, active, inactive, wired, comp }')"

  to_mb() { awk -v p="$1" -v ps="$PAGESIZE" 'BEGIN{ printf "%.0f", p*ps/1024/1024 }'; }
  FREE_MB=$(to_mb "$FREE")
  ACTIVE_MB=$(to_mb "$ACTIVE")
  INACTIVE_MB=$(to_mb "$INACTIVE")
  WIRED_MB=$(to_mb "$WIRED")
  COMP_MB=$(to_mb "$COMPRESSED")

  # System-wide file descriptors
  KERN_NUM=$(sysctl -n kern.num_files 2>/dev/null)
  KERN_MAX=$(sysctl -n kern.maxfiles 2>/dev/null)
  FD_PCT=$(awk -v n="$KERN_NUM" -v m="$KERN_MAX" 'BEGIN{ if(m>0) printf "%.1f", n*100/m; else print "?" }')

  # Top 3 by RSS (cheap)
  TOP3=$(ps -axo pid,rss,comm | sort -k2 -rn | head -3 | awk '{ printf "%s(%dMB) ", $3, $2/1024 }')

  # Top 3 FD holders — lsof is slow, only sample every ~5 min
  if [ $(( $(date +%s) % 300 )) -lt "$INTERVAL" ]; then
    TOPFD=$(lsof 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -3 | awk '{ printf "%s(%d) ", $2, $1 }')
  else
    TOPFD="(skipped)"
  fi

  # Docker activity (best-effort; 5s timeout in case the daemon is hung)
  DOCKER_PS=$(timeout 5 docker ps -q 2>/dev/null | wc -l | tr -d ' ')
  DOCKER_BUILDS=$(pgrep -fl "docker build" 2>/dev/null | awk '$0 !~ /pgrep|mac-watch/' | wc -l | tr -d ' ')
  # VM detection — Docker Desktop uses Apple Virtualization XPC; OrbStack uses its own vmgr helper
  DOCKER_VM_PID=$(pgrep -x "com.apple.Virtualization.VirtualMachine" 2>/dev/null | head -1)
  if [ -z "$DOCKER_VM_PID" ]; then
    DOCKER_VM_PID=$(pgrep -f "OrbStack Helper vmgr" 2>/dev/null | head -1)
    VM_KIND="orb"
  else
    VM_KIND="dd "
  fi
  if [ -n "$DOCKER_VM_PID" ]; then
    DOCKER_VM_RSS_MB=$(ps -p "$DOCKER_VM_PID" -o rss= 2>/dev/null | awk '{printf "%d", $1/1024}')
    DOCKER_VM_FDS=$(lsof -p "$DOCKER_VM_PID" 2>/dev/null | wc -l | tr -d ' ')
  else
    DOCKER_VM_RSS_MB=0
    DOCKER_VM_FDS=0
    VM_KIND="-- "
  fi

  printf '%s | mem free=%5sMB active=%6sMB inactive=%6sMB wired=%5sMB compressor=%5sMB | fds=%6s/%6s (%s%%) | docker: ps=%s builds=%s vm=%s vm_rss=%sMB vm_fds=%s | rss-top3: %s | fd-top3: %s\n' \
    "$TS" "$FREE_MB" "$ACTIVE_MB" "$INACTIVE_MB" "$WIRED_MB" "$COMP_MB" \
    "$KERN_NUM" "$KERN_MAX" "$FD_PCT" \
    "$DOCKER_PS" "$DOCKER_BUILDS" "$VM_KIND" "$DOCKER_VM_RSS_MB" "$DOCKER_VM_FDS" \
    "$TOP3" "$TOPFD" >> "$LOG"

  sleep "$INTERVAL"
done

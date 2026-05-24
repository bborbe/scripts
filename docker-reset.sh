#!/usr/bin/env bash
# docker-reset.sh — Restart Docker Desktop to clear its VM's FD + RAM leak.
#
# Docker Desktop's Virtualization.framework VM accumulates file descriptors and
# memory over its lifetime and does not release them, even when idle (e.g. after
# a `docker build` finishes). Restarting the app resets the VM and frees the
# resources. This is currently the cheapest workaround until either:
#   - macOS 26.x ships a launchd fix
#   - Docker Desktop ships a fix
#   - We switch to OrbStack (see Obsidian task)
#
# Usage:
#   ./docker-reset.sh            # quit + restart Docker Desktop
#   ./docker-reset.sh --quit     # only quit (don't restart)
#
# Reports kern.num_files before/after so you can verify the reclaim.

set -eu

MODE=${1:-restart}

before=$(sysctl -n kern.num_files)
vm_pid=$(pgrep -x com.apple.Virtualization.VirtualMachine 2>/dev/null | head -1 || true)
if [ -n "${vm_pid:-}" ]; then
  vm_rss_mb=$(ps -p "$vm_pid" -o rss= | awk '{printf "%.0f", $1/1024}')
  vm_fds=$(lsof -p "$vm_pid" 2>/dev/null | wc -l | tr -d ' ')
  echo "Before: kern.num_files=$before  vm_rss=${vm_rss_mb}MB  vm_fds=$vm_fds"
else
  echo "Before: kern.num_files=$before  (no Docker VM running)"
fi

echo "Quitting Docker Desktop..."
osascript -e 'quit app "Docker"' || true

# Wait for VM process to exit (max 30s)
for _ in $(seq 1 30); do
  pgrep -x com.apple.Virtualization.VirtualMachine >/dev/null || break
  sleep 1
done

after_quit=$(sysctl -n kern.num_files)
echo "After quit:  kern.num_files=$after_quit  (freed $((before - after_quit)) FDs)"

if [ "$MODE" = "--quit" ]; then
  exit 0
fi

echo "Restarting Docker Desktop..."
open -a Docker
echo "Docker is starting in the background. \`docker ps\` will work once it finishes booting (~10-30s)."

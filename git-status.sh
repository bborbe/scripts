#!/usr/bin/env bash
# git-status.sh - fast parallel git status across many repos
#
# Usage: git-status.sh [BASE_DIR]
#   BASE_DIR defaults to $PWD
#
# Env:
#   JOBS=N   parallel workers (default 8)
#
# Always runs `git fetch -p` so "behind" count is current.
#
# Output columns: repo  branch  clean|DIRTY|LOCKED  behind=N
#   behind = commits on origin/master not in HEAD
set -u
BASE="${1:-$PWD}"
BASE="${BASE%/}"
JOBS="${JOBS:-8}"

check_repo() {
  local repo="$1"
  cd "$repo" || return
  if [ -f "$repo/.git/index.lock" ]; then
    printf "%-25s %-30s %-6s %s\n" "${repo#$BASE/}" "-" "LOCKED" "skipped"
    return
  fi
  local branch dirty behind
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)
  git fetch -p --quiet 2>/dev/null
  if git diff-index --quiet HEAD -- 2>/dev/null; then
    dirty="clean"
  else
    dirty="DIRTY"
  fi
  if git rev-parse --verify -q origin/master >/dev/null; then
    behind=$(git rev-list --count HEAD..origin/master 2>/dev/null)
  else
    behind="?"
  fi
  printf "%-25s %-30s %-6s behind=%s\n" "${repo#$BASE/}" "$branch" "$dirty" "$behind"
}
export -f check_repo
export BASE

find "$BASE" -maxdepth 3 -name ".git" -type d -prune \
    ! -path "*/vendor/*" ! -path "*/node_modules/*" \
  | sed 's|/.git$||' \
  | xargs -P "$JOBS" -I{} bash -c 'check_repo "$@"' _ {} \
  | sort

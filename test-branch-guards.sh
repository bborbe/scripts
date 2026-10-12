#!/usr/bin/env bash
#
# Tests for git-protect-branches and git-pin-worktree.
#
# Usage: bash test-branch-guards.sh   (exit 0 = all pass)
#
# These scripts only WRITE config; enforcement lives in the global hooks of
# bborbe/dotfiles. So the suite asserts on the config each script leaves behind
# — and, for pins, on the scope it lands in, since the hook honours only the
# worktree scope. A pin written to the shared --local config would pin the main
# checkout too and break `git worktree add`.
#
# core.hooksPath points at an empty dir so the machine's own hooks never run.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
protect="$here/git-protect-branches"
pin="$here/git-pin-worktree"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/nohooks"

pass=0
fail=0

check() { # check <description> <got> <want>
	if [ "$2" = "$3" ]; then
		pass=$((pass + 1))
		printf '  ok   %s\n' "$1"
	else
		fail=$((fail + 1))
		printf '  FAIL %s — got [%s] want [%s]\n' "$1" "$2" "$3"
	fi
}

repo="$scratch/repo"
git init -q -b master "$repo"
(
	cd "$repo"
	git config user.email t@t
	git config user.name t
	git config core.hooksPath "$scratch/nohooks"
	git commit -q --allow-empty -m seed
	git branch dev
	git branch prod
	git worktree add -q "$scratch/repo-dev" dev
)

echo "git-protect-branches"
cd "$repo"
check "nothing protected by default" "$("$protect")" "protected: none"
"$protect" master dev >/dev/null
check "sets the list in local config" "$(git config --local --get hook.protectBranches)" "master dev"
check "the list is visible from a linked worktree" "$(cd "$scratch/repo-dev" && git config --get hook.protectBranches)" "master dev"
"$protect" --unset >/dev/null
check "--unset clears it" "$(git config --local --get hook.protectBranches || echo none)" "none"
rc=0
"$protect" --bogus >/dev/null 2>&1 || rc=$?
check "an unknown option is refused" "$rc" "2"

echo "git-pin-worktree"
rc=0
"$pin" >/dev/null 2>&1 || rc=$?
check "refuses in a main checkout" "$rc" "1"
check "main checkout carries no pin after the refusal" "$(git config --get hook.pinBranch || echo none)" "none"

cd "$scratch/repo-dev"
rc=0
"$pin" prod >/dev/null 2>&1 || rc=$?
check "refuses a branch the worktree is not on" "$rc" "1"

"$pin" >/dev/null
check "pins the current branch" "$(git config --worktree --get hook.pinBranch)" "dev"
check "the pin lands in the WORKTREE scope" "$(git config --show-scope --get hook.pinBranch | cut -f1)" "worktree"
check "extensions.worktreeConfig was enabled" "$(git config --local --get extensions.worktreeConfig)" "true"
check "the pin does not leak to the main checkout" "$(cd "$repo" && git config --get hook.pinBranch || echo none)" "none"
check "--show reports it" "$("$pin" --show)" "pinned: dev"
"$pin" --unset >/dev/null
check "--unset removes it" "$(git config --worktree --get hook.pinBranch || echo none)" "none"

git checkout -q --detach
rc=0
"$pin" >/dev/null 2>&1 || rc=$?
check "refuses on a detached HEAD" "$rc" "1"

echo "pass=$pass fail=$fail"
[ "$fail" -eq 0 ]

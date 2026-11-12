test: check

check:
	shellcheck -S error *.sh git-protect-branches git-pin-worktree
	bash test-branch-guards.sh

precommit: check

.PHONY: test check precommit

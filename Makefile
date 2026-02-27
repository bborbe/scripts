test: check

check:
	shellcheck -S error *.sh

precommit: check

.PHONY: test check precommit

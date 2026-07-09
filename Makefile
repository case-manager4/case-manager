# Case-Manager — dev targets (the shipped tool has zero runtime deps)
# bats + shellcheck are dev-only; install with:
#   npm install -g bats   (or: apt-get install bats)
#   apt-get install shellcheck

SCRIPT := case-manager
TESTS  := test/

.PHONY: test lint check

test:
	bats $(TESTS)

lint:
	shellcheck $(SCRIPT)

# Quick parse-only sanity check (no deps required)
check:
	bash -n $(SCRIPT)

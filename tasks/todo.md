# Tasks: Harden & Document `case-manager`

- [ ] Task: Add safety header (set -euo pipefail, nullglob, TTY color guard)
  - Acceptance: Script fails loudly; colors absent when piped; empty-dir listing safe.
  - Verify: `./case-manager list` in empty dir → "No cases found."; `./case-manager list | cat -v` shows no ESC.
  - Files: case-manager

- [ ] Task: Harden `validate_name` (reject ., .., ..-substring, non-printable)
  - Acceptance: Rejects `.`, `..`, `a..b`, `name`+newline; accepts `[a-zA-Z0-9._-]+`.
  - Verify: source script, call validate_name on each; bats cases.
  - Files: case-manager

- [ ] Task: Apply validation to delete/archive/status/rename-old
  - Acceptance: `delete ..`, `delete /etc`, `archive ../x`, `status .` all exit 1, no rm/tar runs.
  - Verify: bats cases for each dangerous input.
  - Files: case-manager

- [ ] Task: Rewrite error handling for set -e (if ! cmd; then) + $@/${n:-}
  - Acceptance: No `[[ $? ]]` after bare external calls; no unbound-var on missing arg.
  - Verify: delete/archive/rename with one arg still behave; bats.
  - Files: case-manager

- [ ] Task: Guard cmd_open find substitution with || true
  - Acceptance: open still works; never exits under set -e on find error.
  - Verify: open with no cases → graceful error exit 1; bats.
  - Files: case-manager

- [ ] Task: Write bats suite test/case-manager.bats
  - Acceptance: Covers all 8 commands + every rejection rule; passes.
  - Verify: `bats test/` (or sourced-function smoke test) green.
  - Files: test/case-manager.bats

- [ ] Task: Rewrite README.md (full reference + examples + validation + test/lint)
  - Acceptance: Every command documented with example; validation rules listed; test/lint shown.
  - Verify: README matches actual commands/behavior.
  - Files: README.md

- [ ] Task: Add Makefile (test, lint)
  - Acceptance: `make test` runs bats; `make lint` runs shellcheck.
  - Verify: `make` targets present and correct.
  - Files: Makefile

# Plan: Harden & Document `case-manager`

## Components & dependencies

1. **Safety header** — `set -euo pipefail`, `shopt -s nullglob`, TTY color guard.
   (No dependency; must come first so all later code benefits.)
2. **`validate_name` hardening** — add rejection of `.` / `..` / `..`-substring and
   non-printable chars. (No dependency; used by all commands.)
3. **Consistent validation at call sites** — `delete`, `archive`, `status`,
   `rename` (old name) now call `validate_name` + existence checks. (Depends on #2.)
4. **`set -e`-safe error handling** — convert `cmd; if [[ $? ]]` patterns to
   `if ! cmd; then ...`. (Depends on #1.) Also `cmd_* "$@"` + `${1:-}`/`${2:-}`
   to satisfy `set -u`.
5. **`cmd_open` safety** — guard the `find` command substitution with `|| true`;
   behavior unchanged (still opens latest mtime subdir).
6. **bats suite** — `test/case-manager.bats` covering every command + rule.
   (Depends on #2–#4 being correct.)
7. **README rewrite** — full reference, examples, validation rules, test/lint.
8. **Makefile** — `test` (bats) and `lint` (shellcheck) targets.

## Implementation order (sequential until #6, which verifies all prior)

1 → 2 → 3 → 4 → 5  (code edits, interdependent, do in one pass)
        → 6 (tests, verify the edits)
        → 7 (README)
        → 8 (Makefile)

## Risks & mitigation

- **`set -e` causing early exits** where old code relied on `$?`: mitigated by
  rewriting every external call as `if ! cmd; then`. Verified by the bats suite.
- **`set -u` on unset positional args** (`$2` when only one arg): mitigated by
  passing `"$@"` and using `${2:-}`.
- **bats/shellcheck not installed in this env**: suite + lint are written and
  documented; logic is also verified by sourcing functions directly in bash.

## Verification checkpoints

- After code edits: source the script's functions in a throwaway dir and assert
  `validate_name` rejects `..`/`/etc` and `cmd_delete` refuses to run `rm` on them.
- After tests written: `bats test/` (or, if unavailable, the sourced-function smoke test) green.
- README: every command listed with a runnable example; `make test`/`make lint` documented.

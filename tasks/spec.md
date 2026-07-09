# Spec: Harden & Document `case-manager` (v1.0.0 → v1.1.0)

## Objective

The existing pure-Bash digital-forensics case tool works for the happy path but has
inconsistent input validation, no crash-safety, and a truncated README. This pass
**fixes the real defects**, **closes a path-traversal / arbitrary-delete hazard**,
**modernizes shell safety**, and **completes the documentation**. The shipped tool
remains **pure Bash, zero runtime dependencies**.

Success is: every command sanitizes its target, the script fails loudly and safely,
colors never pollute logs, and a bats suite proves the behavior.

## Tech Stack

- **Runtime:** Bash 4+ (no external runtime deps — coreutils only).
- **Dev/Test (optional, not shipped):** `bats` (Bash Automated Testing System) for the suite; `shellcheck` for lint.
- Both dev tools are installable without touching the shipped artifact.

## Commands

```bash
# Run the test suite (after: npm i -g bats  OR  apt-get install bats)
bats test/

# Lint the script (after: apt-get install shellcheck)
shellcheck case-manager

# Build: none (single-file bash; make executable)
chmod +x case-manager

# Run any command
./case-manager <command> [options] [args]
```

A `Makefile` exposes `make test` and `make lint`.

## Project Structure

```
case-manager        → The tool (single Bash script, pure, zero runtime deps)
README.md           → Full command reference, examples, validation rules (rewritten)
Makefile            → test / lint targets
tasks/
  spec.md           → This document
  plan.md           → Implementation plan
  todo.md           → Task checklist
test/
  case-manager.bats → bats suite covering every command + validation
```

## Code Style

Match the existing style: `local` declarations, `cmd_*` functions, `log_*` helpers,
explicit `if ! cmd; then` error handling (never rely on `$?` after a bare call
under `set -e`). Example of the required pattern:

```bash
# WRONG (fails under set -e; exit happens before the check)
mkdir -p "$name"/{images,reports,logs,evidence} 2>/dev/null
if [[ $? -ne 0 ]]; then log_error "..."; exit 1; fi

# RIGHT
if ! mkdir -p "$name"/{images,reports,logs,evidence} 2>/dev/null; then
    log_error "mkdir failure: check permissions."
    exit 1
fi
```

Color is emitted only when stdout is a TTY (`[ -t 1 ]`); otherwise the color vars
are empty strings so redirected/piped output stays clean.

## Testing Strategy

- **Framework:** `bats` (dev-only). Tests live in `test/case-manager.bats`.
- **Approach:** Each test runs the script in an isolated `mktemp` directory (cases are
  CWD-relative), exercising one command and asserting on exit status + output.
- **Coverage required:** every command + every validation rejection rule
  (empty, `/`, leading dot, spaces, `..`, newline/non-printable, duplicate).
- **Verification checkpoint:** `bats test/` must pass before the work is called done.

## Boundaries

- **Always:** keep pure-Bash zero-runtime-dependency; validate every case name; fail loudly; update README with any command/behavior change.
- **Ask first:** adding a runtime dependency, changing the case directory layout (the 4 subdirs), changing the public CLI surface.
- **Never:** commit secrets; edit outside the repo; remove a test to make it pass; weaken validation for convenience.

## Success Criteria (testable)

1. `validate_name` rejects: empty, `/`, leading `.`, any whitespace, `.`, `..`, any `..` substring, and any non-printable char (e.g. trailing newline). Accepts `[a-zA-Z0-9._-]+`.
2. `delete`, `archive`, `status`, and `rename` (old name) all sanitize the target — `case-manager delete ..` and `case-manager delete /etc` are refused with exit 1 (no `rm -rf` executes).
3. Script runs under `set -euo pipefail`; `shopt -s nullglob` is set so empty-dir listing is safe.
4. When stdout is not a TTY, output contains no ANSI escape sequences.
5. `cmd_create` still builds `images/ reports/ logs/ evidence/` and rejects an existing name.
6. Full `bats test/` suite passes (all commands + all rejection rules).
7. `README.md` documents every command with examples, the validation rules, install, and the test/lint commands.

## Open Questions

- None blocking. (Optional future: restrict `open` to directories that contain the
  case structure; deferred as a known limitation, not a defect.)

# Case-Manager

**Digital Forensics Case Lifecycle Tool — Pure Bash, zero runtime dependencies.**

Create, organize, manage, and archive digital-forensics investigation case
directories from the command line. A single Bash script with no external runtime
dependencies (coreutils only), hardened against path-traversal and arbitrary-delete
mistakes.

---

## Requirements

- **Bash 4+** (pre-installed on every Linux distribution)
- **coreutils** (`ls`, `mkdir`, `find`, `stat`, `date`, `tar`, `rm`, `mv`, `du`) — pre-installed on every Linux distribution
- *Optional:* `xdg-open`, `thunar`, `nautilus`, `dolphin`, or `nemo` for the `open` command
- *Optional (dev only):* [`bats`](https://github.com/bats-core/bats-core) to run the test suite, and [`shellcheck`](https://github.com/koalaman/shellcheck) to lint

> The shipped tool is **pure Bash with zero runtime dependencies**. `bats` and
> `shellcheck` are used only to develop/test it — end users never need them.

---

## Installation

```bash
# Download
curl -O https://raw.githubusercontent.com/T3rmx/case-manager/main/case-manager

# Make executable
chmod +x case-manager

# Move to PATH
sudo mv case-manager /usr/local/bin/
```

---

## Commands

All commands are run from the directory where you keep your cases (cases are
created as subdirectories of the current working directory).

| Command | Description |
|---|---|
| `case-manager create <name>` | Create a new structured case directory with `images/`, `reports/`, `logs/`, `evidence/` subdirectories |
| `case-manager open` | Open the most recently modified case in your file manager |
| `case-manager list` | List all cases with last-modified timestamps |
| `case-manager archive <name>` | Compress a case into `<name>.tar.gz` |
| `case-manager delete [--force] <name>` | Delete a case directory (prompts for confirmation unless `--force`) |
| `case-manager rename <old> <new>` | Rename a case directory |
| `case-manager status <name>` | Show case location, total size, and per-subdirectory file counts |
| `case-manager help` | Show the usage summary |
| `case-manager version` | Show the version string |

### Examples

```bash
# Create a new case
case-manager create acme-breach-2026
#   ├── images/     # Forensic images, screenshots, photos
#   ├── reports/    # Investigation reports, findings
#   ├── logs/       # System logs, audit trails
#   └── evidence/   # Collected evidence files

# List cases
case-manager list

# Inspect a case
case-manager status acme-breach-2026

# Archive for hand-off / storage
case-manager archive acme-breach-2026      # -> acme-breach-2026.tar.gz

# Rename
case-manager rename acme-breach-2026 acme-incident-2026

# Delete (asks for confirmation)
case-manager delete acme-incident-2026
# Non-interactive:
case-manager delete --force acme-incident-2026

# Open the latest case in a file manager
case-manager open
```

---

## Case Name Validation

Every command validates its `<name>` argument through a single chokepoint. A case
name must match `^[a-zA-Z0-9._-]+$` and additionally must **not**:

- be empty
- contain a slash `/` (prevents path traversal)
- start with a dot `.` (prevents hidden directories)
- be exactly `.` or `..`
- contain `..` anywhere (prevents `../` traversal)
- contain whitespace
- contain any non-printable character (e.g. a stray newline)

This validation is applied consistently to `create`, `delete`, `archive`,
`status`, and `rename` (both the old and new names). As a result, commands like
`case-manager delete ..`, `case-manager delete /etc`, or `case-manager archive
../foo` are **refused before any destructive command runs** — the tool will
print an error and exit non-zero rather than execute `rm`/`tar` on an unexpected
path.

---

## Safety & Robustness

- Runs under `set -euo pipefail` and `shopt -s nullglob`, so it fails loudly and
  safely (no silent partial failures, safe listing in empty directories).
- ANSI color output is emitted **only when writing to a terminal**. When output is
  piped or redirected to a file, no escape sequences are written — your logs stay
  clean.
- All destructive operations (`delete`) prompt for confirmation by default.

---

## Development

The repository includes an automated test suite and a lint target.

### Running the tests (bats)

```bash
# Install bats (choose one)
npm install -g bats          # or: apt-get install bats

# Run
make test
# or directly:
bats test/
```

> No `bats` installed? It can be fetched transiently with:
> `npx --yes bats@1 test/`

### Linting (shellcheck)

```bash
# Install: apt-get install shellcheck
make lint
# or directly:
shellcheck case-manager
```

### Makefile targets

| Target | Runs |
|---|---|
| `make test` | `bats test/` |
| `make lint` | `shellcheck case-manager` |

The suite (`test/case-manager.bats`) exercises every command and every validation
rule, including the path-traversal refusals, in isolated temporary directories.

---

## Project Layout

```
case-manager        → The tool (single Bash script, pure, zero runtime deps)
README.md           → This document
Makefile            → test / lint targets
tasks/
  spec.md           → Specification (objective, scope, success criteria)
  plan.md           → Implementation plan
  todo.md           → Task checklist
test/
  case-manager.bats → bats test suite
```

---

## License

See repository for license details.

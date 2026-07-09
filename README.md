# Case-Manager

**Digital Forensics Case Lifecycle Tool — Pure Bash, zero dependencies.**

Create, organize, and manage digital forensics investigation case directories from the command line.

---

## Requirements

- **Bash 4+** (pre-installed on every Linux distribution)
- **coreutils** (`ls`, `mkdir`, `find`, `stat`, `date`, `tar`, `rm`, `mv`, `du`) — pre-installed on every Linux distribution
- *Optional:* `xdg-open`, `thunar`, `nautilus`, `dolphin`, or `nemo` for the `open` command

---

## Installation

```bash
# Download
curl -O [https://raw.githubusercontent.com/T3rmx/case-manager/main/case-manager](https://raw.githubusercontent.com/T3rmx/case-manager/main/case-manager)

# Make executable
chmod +x case-manager

# Move to PATH
sudo mv case-manager /usr/local/bin/

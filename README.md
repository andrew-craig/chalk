# hopper
A very simple task management system built for agents

## Installation

Run the following from the root of any git repository:

```bash
curl -fsSL https://raw.githubusercontent.com/andrew-craig/hopper/main/install.sh | bash
```

This will:
- Create a `.hopper/scripts` directory in your repo
- Download the `hpr` script
- Add it to your `PATH`

After installing, open a new terminal or run `source ~/.bashrc` (or `~/.zshrc`) to start using the `hpr` command.

## Tasks Overview

Each task has a **type**, **status**, and **priority**.

### Types

| Type | Description |
|------|-------------|
| `task` | General task |
| `bug` | Bug fix |
| `feature` | Feature request or implementation |
| `chore` | Maintenance or housekeeping |
| `epic` | Epic or major feature |
| `decision` | Decision or design document |

### Statuses

| Status | Description |
|--------|-------------|
| `open` | Initial state |
| `in_progress` | Currently being worked on |
| `blocked` | Blocked by dependencies |
| `deferred` | Deferred for later |

Tasks can also be closed via `hpr close`.

### Priorities

| Priority | Level |
|----------|-------|
| `0` | Critical |
| `1` | High |
| `2` | Medium (default) |
| `3` | Low |
| `4` | Backlog |

## Install in Claude Code (including web)

To install in Claude Code, including Claude Code web instances, create a session-start.sh file with the below content. Add this to your `.claude/hooks/` directory

```
#!/bin/bash
set -euo pipefail

# Derive paths from script location, independent of env vars
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
HPR_DIR="$PROJECT_DIR/.hopper/scripts"

# Add hpr script to PATH for this session
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
   Harness supports env file injection — write an absolute path (not $CLAUDE_PROJECT_DIR)
  echo "export PATH=\"$HPR_DIR:\$PATH\"" >> "$CLAUDE_ENV_FILE"
else
  # Fallback: symlink into a directory already on PATH
  LOCAL_BIN="$HOME/.local/bin"
  mkdir -p "$LOCAL_BIN"
  ln -sf "$HPR_DIR/hpr" "$LOCAL_BIN/hpr"
fi
```

Then add the below to your .claude/settings.json file:
(this sits at the same level in the json as env and permissions)

```
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
```

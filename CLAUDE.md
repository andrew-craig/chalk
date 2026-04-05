# CLAUDE.md

## Project Overview

Hopper is a file-based task management system built for AI agents. It provides a single bash CLI tool (`hpr`) that stores tasks as markdown files with YAML frontmatter in a `tasks/` directory.

## Repository Structure

```
hopper/
├── CLAUDE.md          # This file
├── LICENSE            # MIT License
├── README.md          # Project description
├── scripts/
│   └── hpr            # Main CLI tool (bash script, invoked as `hpr`)
└── tasks/             # Task storage (created at runtime)
    └── closed/        # Archived closed tasks
```

## Running the Tool

```bash
# Run directly
./scripts/hpr <command> [args]

# Or add to PATH and use as `hpr`
export PATH="$PATH:$(git rev-parse --show-toplevel)/scripts"
hpr <command> [args]
```

The tasks directory location can be overridden with the `HPR_DIR` environment variable.

## Commands

| Command | Description |
|---------|-------------|
| `hpr create "title" [opts]` | Create a new task |
| `hpr show <id>` | Display full task details |
| `hpr list [filters]` | List tasks with optional filters |
| `hpr update <id> [fields]` | Update task fields |
| `hpr close <id>` | Close a task (moves to `tasks/closed/`) |
| `hpr ready` | Show open unblocked tasks sorted by priority |
| `hpr help` | Show usage information |

## Task File Format

Tasks are markdown files with YAML frontmatter stored as `tasks/<type>_<hex>.md`:

```markdown
---
id: task_a3f2
title: Example task
type: task
status: open
priority: 2
labels: []
blocked_by: []
parent: null
created_at: 2026-03-22T00:00:00Z
updated_at: 2026-03-22T00:00:00Z
---
Optional description body here.
```

### Field Values

- **type**: `task`, `bug`, `feature`, `chore`, `epic`, `decision`
- **status**: `open`, `in_progress`, `blocked`, `deferred` (plus `closed` for archived tasks)
- **priority**: `0` (critical), `1` (high), `2` (medium/default), `3` (low), `4` (backlog)
- **labels**: YAML list of tags, e.g. `[auth, backend]`
- **blocked_by**: YAML list of task IDs; closing a blocker auto-unblocks dependents
- **parent**: task ID for sub-task relationships, or `null`

## Key Behaviors

- **Auto-unblock**: When a task is closed, any tasks listing it in `blocked_by` are automatically updated. If all blockers are resolved, a `blocked` task flips back to `open`.
- **Type rename**: Changing a task's type via `--type=` also renames the file to match the new type prefix.
- **ID format**: IDs are `<type>_<4-hex-chars>` (e.g. `bug_a3f2`). The hex portion is random.
- **Closed tasks** are moved from `tasks/` to `tasks/closed/` and cannot be updated via the CLI.

## Development Conventions

- **Language**: Pure bash (no external dependencies beyond coreutils)
- **Shell settings**: `set -euo pipefail` — scripts fail on errors, undefined variables, and pipe failures
- **No build step**: The script runs directly; no compilation or transpilation
- **No test framework**: Currently no automated tests
- **No linter/formatter**: No shellcheck or shfmt configured
- **No CI/CD**: No GitHub Actions or similar pipelines

## Code Architecture

The script (`scripts/hpr`) is organized into three sections:

1. **Helpers** (lines 14–114): Utility functions for ID generation, YAML field reading/writing, task lookup, validation, and table formatting
2. **Commands** (lines 118–492): One `cmd_*` function per subcommand (`create`, `show`, `list`, `update`, `close`, `ready`, `help`)
3. **Entry point** (lines 496–514): Argument parsing that dispatches to the appropriate command function

## When Modifying This Project

- Keep the single-file bash architecture; avoid adding external dependencies
- Maintain `set -euo pipefail` safety guarantees
- Validate all user inputs (types, statuses, priorities) before writing to files
- Preserve the YAML frontmatter format — other tools may parse these files
- Task IDs must remain unique across both `tasks/` and `tasks/closed/`
- Use `mktemp` for atomic file updates (see `update_field`)

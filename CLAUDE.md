# CLAUDE.md

## Project Overview

Chalk is a file-based task management system designed for AI agents. It is a single bash CLI tool (`chalk`) that stores tasks as markdown files with YAML frontmatter inside `.chalk/tasks/` at the repo root, so tasks are versioned alongside the code they describe.

A repo opts in with `chalk init`, after which agents and humans use the same handful of commands (`create`, `show`, `list`, `ready`, `update`, `close`) to manage work. Optional GitHub Issues sync is available through the `ghi` subcommand.

## Core Principles

These principles drive every design decision in chalk. New features and modifications must preserve them.

1. **Plain files are the source of truth.** Tasks are markdown files with YAML frontmatter — readable, greppable, diffable, and editable by humans, agents, and other tools without going through the CLI. The CLI is a convenience layer, never a gatekeeper for the data format.
2. **Single-file bash, no dependencies.** The entire tool is one bash script (`scripts/chalk`). It relies only on coreutils, `awk`, `sed`, `find`, and `git`. The optional `ghi` subcommand additionally requires the `gh` CLI. Adding a runtime dependency requires strong justification.
3. **Agent-first ergonomics.** Output is structured and predictable: tables for humans, `--output=ids` for machine parsing, an `[exit:N | Nms]` metadata footer on every non-help invocation. Error messages name the valid options and include a concrete example. Every command supports `--help`.
4. **Git-native, repo-local.** Tasks live in `.chalk/tasks/` inside the repo, branch with the code, and are intended to be committed. There is no global database. `CHALK_DIR` can override the location for edge cases.
5. **Local-first; remote is optional.** Chalk works fully offline. GitHub Issues integration (`ghi clone`, `ghi push`, `ghi sync`) is opt-in and layered on top — never a requirement.
6. **Automatic state propagation.** Closing a task auto-unblocks dependents (and flips `blocked` tasks back to `open` when all blockers are resolved). Closing the last child of a parent reports epic completion. Changing a task's type renames its file.
7. **Atomic, validated writes.** Field updates go through `mktemp` + `mv`. Types, statuses, and priorities are validated before they touch disk. Closed tasks are immutable through the CLI — modify them by editing the file directly or reopening via `ghi sync`.
8. **Convention over configuration.** IDs are always `<type>_<4-hex>`. Filenames mirror IDs. Defaults are sensible (`type=task`, `priority=2`, `status=open`). There is no config file.

## Repository Structure

```
chalk/
├── CLAUDE.md                       # This file
├── README.md                       # User-facing description and install instructions
├── LICENSE                         # MIT
├── install.sh                      # Downloads chalk into ~/.local/bin and updates PATH
├── scripts/
│   └── chalk                       # The CLI (single bash script — the entire tool)
├── skill/
│   └── chalk-task-manager/         # Claude Code skill that teaches agents to use chalk
│       ├── SKILL.MD
│       └── task_installation.md
├── .claude/
│   ├── settings.json               # Allows `chalk:*` bash invocations; registers session hook
│   └── hooks/
│       └── session-start.sh        # Installs chalk in remote Claude (Web) sessions
└── .chalk/                         # This repo's own task directory (dogfooding)
    ├── scripts/chalk               # Snapshot installed by the session hook (not the source)
    └── tasks/                      # Active tasks; closed tasks live in tasks/closed/
```

The canonical source for the `chalk` script is `scripts/chalk`. `.chalk/scripts/chalk` is a snapshot from a prior install of this repo into itself and should not be edited — changes belong in `scripts/chalk`.

## Installation Model

Users install via `curl … install.sh | bash`, which drops the script in `~/.local/bin` and adds it to `PATH`. From inside any git repo, `chalk init` creates `.chalk/tasks/` (and `.chalk/tasks/closed/`). The script locates the repo via `git rev-parse --show-toplevel` and stores tasks in `$REPO_ROOT/.chalk/tasks/` unless `CHALK_DIR` is set.

For Claude Code Web sessions, `.claude/hooks/session-start.sh` re-runs the installer and injects the bin directory into the session `PATH` via `CLAUDE_ENV_FILE`.

## Commands

| Command | Description |
|---------|-------------|
| `chalk init` | Create `.chalk/tasks/` and `.chalk/tasks/closed/` at the repo root |
| `chalk create "title" [opts]` | Create a new task |
| `chalk show <id>` | Display full task details (frontmatter + body) |
| `chalk list [filters]` | List tasks; supports `--status=`, `--type=`, `--priority=`, `--parent=`, `--closed`, `--limit=`, `--output=ids` |
| `chalk ready [opts]` | Show open, unblocked tasks sorted by priority (the canonical "what should I work on" command); supports `--parent=`, `--output=ids` |
| `chalk update <id> [fields]` | Update task fields; `--type=` also renames the file |
| `chalk close <id>` | Close a task, move it to `.chalk/tasks/closed/`, auto-unblock dependents, announce epic completion |
| `chalk ghi clone` | Clone open GitHub issues as local tasks (skips already-cloned issues by URL) |
| `chalk ghi push <id> [--all]` | Create GitHub issues from local tasks; stores the resulting URL in `remote_task_url` |
| `chalk ghi sync [id]` | Bidirectional sync with linked GitHub issues based on `updated_at` timestamps |
| `chalk help` | Show top-level usage |

Every non-help invocation prints a trailing `[exit:<code> | <elapsed>ms]` footer to make output machine-parseable for agent harnesses.

## Task File Format

Tasks are stored as `.chalk/tasks/<id>.md` where `<id>` is `<type>_<4-hex>`:

```markdown
---
id: bug_a3f2
title: Fix login error on mobile
type: bug
status: open
priority: 1
labels: [auth, mobile]
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-03-22T00:00:00Z
updated_at: 2026-03-22T00:00:00Z
---
Optional description body here.
```

### Field Values

- **type**: `task`, `bug`, `feature`, `chore`, `epic`, `decision`
- **status**: `open`, `in_progress`, `blocked`, `deferred` (plus `closed` for archived tasks)
- **priority**: `0` (critical), `1` (high), `2` (medium / default), `3` (low), `4` (backlog)
- **labels**: YAML list of free-form tags, e.g. `[auth, backend]`
- **blocked_by**: YAML list of task IDs; closing a blocker auto-prunes this list
- **parent**: task ID for sub-task / epic relationships, or `null`
- **remote_task_url**: URL of a linked GitHub issue, or `null`

## Key Behaviors

- **Auto-unblock on close**: Closing a task scans active tasks, removes the closed ID from any `blocked_by` lists, and flips dependents back to `open` once their `blocked_by` is empty.
- **Epic completion**: Closing the last open child of a parent task prints a `complete: <parent_id>` message.
- **Type rename**: `chalk update <id> --type=<new>` rewrites the `type` and `id` fields and renames the file to match.
- **Closed-task immutability**: `chalk update` refuses to modify a task with `status: closed`. Reopen by editing the file directly or via `ghi sync`.
- **GitHub label mapping**: `ghi clone` maps issue labels onto chalk fields — `bug`/`feature`/`chore`/`epic`/`decision` set `type`; `critical`/`urgent`/`P1`/etc. set `priority`; remaining labels carry over to the `labels` field.
- **Sync direction**: `ghi sync` compares `updated_at` between local and remote and pulls or pushes accordingly.

## Code Architecture

The script (`scripts/chalk`, ~1100 lines) has three sections:

1. **Helpers** (top of file through ~line 213): ID generation, YAML field read/write (`get_field`, `update_field`, `update_body`, `get_body`), task lookup, validation (`validate_type`, `validate_status`, `validate_priority`), table formatting, and `gh`-related utilities.
2. **Commands** (~line 215 through ~line 1068): one `cmd_<name>` function per subcommand. The `ghi` group dispatches to `ghi_clone`, `ghi_push`, `ghi_sync`.
3. **Entry point** (bottom of file): argument parsing, help short-circuit, and the `EXIT` trap that emits the `[exit:N | Nms]` footer.

## Development Conventions

- **Language**: pure bash, `set -euo pipefail`.
- **No build step, no test framework, no linter, no CI.** The script runs directly.
- **Atomic edits**: all frontmatter mutations go through `update_field`, which writes to a `mktemp` file and `mv`s into place.
- **Validation at boundaries**: validate user input before writing; trust internal state.
- **Error messages**: always include valid options and a concrete example (e.g. `Example: chalk update <id> --status=in_progress`).

## When Modifying This Project

- Edit `scripts/chalk` — never `.chalk/scripts/chalk` (that's a snapshot).
- Keep the single-file bash architecture; don't add runtime dependencies beyond coreutils, `git`, and (for `ghi`) `gh`.
- Preserve `set -euo pipefail` and the YAML frontmatter format — external tools and the skill assume both.
- Maintain ID uniqueness across `.chalk/tasks/` and `.chalk/tasks/closed/`.
- New commands should support `--help`, inherit the `[exit:N | Nms]` footer via the entry-point trap, and follow the error-message convention.
- If a change alters task fields, command surface, or workflow, update the skill (`skill/chalk-task-manager/SKILL.MD`) and `README.md` to match.

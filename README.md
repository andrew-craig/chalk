# chalk
A very simple task management system built for agents

## Installation

Run the following from the root of any git repository:

```bash
curl -fsSL https://raw.githubusercontent.com/andrew-craig/chalk/main/install.sh | bash
```

This will:
- Create a `.chalk/scripts` directory in your repo
- Download the `task` script
- Add it to your `PATH`

After installing, open a new terminal or run `source ~/.bashrc` (or `~/.zshrc`) to start using the `task` command.

## Issue Types

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

Tasks can also be closed via `tsk close`.

### Priorities

| Priority | Level |
|----------|-------|
| `0` | Critical |
| `1` | High |
| `2` | Medium (default) |
| `3` | Low |
| `4` | Backlog |

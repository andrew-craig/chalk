---
id: chore_b60c
title: Clean up chalk show output format for agents
type: chore
status: open
priority: 3
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:52Z
updated_at: 2026-05-08T21:32:52Z
---
The '── task_id ──' and '── description ──' visual separators are decorative noise for agents. Replace with plain key: value output and a simple blank-line separator before the description body. Fewer tokens, easier to parse.

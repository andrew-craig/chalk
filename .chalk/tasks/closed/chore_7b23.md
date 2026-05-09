---
id: chore_7b23
title: Improve closed-task error to suggest valid next actions
type: chore
status: closed
priority: 2
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:57Z
updated_at: 2026-05-08T21:41:31Z
---
When chalk update encounters a closed task it says 'Re-open by editing the file directly' — not a chalk command. Replace with actionable guidance: 'task is closed — use chalk list --closed to inspect it, or chalk create to start a new task.'

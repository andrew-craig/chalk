---
id: feature_662b
title: Truncate large list output with overflow mode
type: feature
status: closed
priority: 2
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:43Z
updated_at: 2026-05-09T03:03:45Z
---
chalk list returns unbounded rows. For large backlogs this is a context budget problem for agents. Implement overflow mode: truncate at N lines, note total count, and suggest filter flags to narrow results. Example footer: '--- showing 50 of 200 tasks. Use --status= --type= --priority= to filter.'

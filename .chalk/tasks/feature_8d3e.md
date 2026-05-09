---
id: feature_8d3e
title: Add machine-readable output mode to list and ready
type: feature
status: open
priority: 2
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:49Z
updated_at: 2026-05-08T21:32:49Z
---
chalk list has built-in filters but no composable output. Add --output=ids flag that emits one task ID per line so agents can pipe results into other chalk commands. Example: chalk list --status=blocked --output=ids | xargs -I{} chalk close {}

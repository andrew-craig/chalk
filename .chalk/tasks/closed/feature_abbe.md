---
id: feature_abbe
title: Add metadata footer to all command output
type: feature
status: closed
priority: 1
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:31Z
updated_at: 2026-05-08T21:36:59Z
---
Every command result should end with [exit:0 | Xms]. Agents use exit codes to confirm success/failure and duration to calibrate cost. Currently chalk produces no structured signal — an agent can only infer success by parsing prose.

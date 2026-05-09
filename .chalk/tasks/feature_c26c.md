---
id: feature_c26c
title: Implement progressive help disclosure
type: feature
status: open
priority: 2
labels: []
blocked_by: []
parent: null
remote_task_url: null
created_at: 2026-05-08T21:32:39Z
updated_at: 2026-05-08T21:32:39Z
---
The article describes 3 levels: (0) command list on bare invocation, (1) usage per command when called with no args, (2) specific params per subcommand. Chalk dumps everything in cmd_help at once and is inconsistent — chalk ghi gives usage, chalk show gives an error, chalk ready gives an error. Normalize so every command returns its own usage when called without required args.

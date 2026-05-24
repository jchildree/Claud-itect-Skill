---
name: caveman-stats
version: "2.0"
category: caveman
execution_speed: fast
token_efficiency: medium
triggers:
  - "/caveman-stats"
  - "token usage"
  - "token savings"
cache_key: "caveman-stats-2.0"
dependencies: []
description: >
  Show real token usage and estimated savings for the current session.
  Reads directly from the Claude Code session log -- no AI estimation.
  Triggers on /caveman-stats. Output is injected by the mode-tracker hook;
  the model itself does not compute the numbers.
---

This skill is delivered by `hooks/caveman-stats.js` (read by `hooks/caveman-mode-tracker.js` on `/caveman-stats`). The model does not need to do anything when this skill fires -- the hook returns `decision: "block"` with the formatted stats as the reason. The user sees the numbers immediately.

## Initiation

If preference not in memory, ask once:

> "Before I start -- what's your favorite movie, book, anime, or show?"

Use answer as light reference -- one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

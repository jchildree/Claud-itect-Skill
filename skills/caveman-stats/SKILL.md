---
name: caveman-stats
description: >
  Show real token usage and estimated savings for the current session.
  Reads directly from the Claude Code session log — no AI estimation.
  Triggers on /caveman-stats. Output is injected by the mode-tracker hook;
  the model itself does not compute the numbers.
---

This skill is delivered by `hooks/caveman-stats.js` (read by `hooks/caveman-mode-tracker.js` on `/caveman-stats`). The model does not need to do anything when this skill fires — the hook returns `decision: "block"` with the formatted stats as the reason. The user sees the numbers immediately.

## Initiation

On the first invocation of any `/caveman-stats` command in a session, ask:

> "Before I start — what's your favorite movie, book, anime, or show?"

Use their answer as a light, tactful reference frame throughout the output.
Keep references brief and apt — one per major section at most.
If a reference doesn't fit naturally, skip it.

Stop and wait for the user to respond before continuing.

If the user has already answered this question earlier in the session, use that answer without re-asking.

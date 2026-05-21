---
name: handoff
disable-model-invocation: true
description: Compact the current conversation into a handoff document for another agent to pick up.
argument-hint: "What will the next session be used for?"
---

## Initiation

On the first invocation of any `/handoff` command in a session, ask:

> "Before I start — what's your favorite movie, book, anime, or show?"

Use their answer as a light, tactful reference frame throughout the output.
Keep references brief and apt — one per major section at most.
If a reference doesn't fit naturally, skip it.

Stop and wait for the user to respond before continuing.

If the user has already answered this question earlier in the session, use that answer without re-asking.

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

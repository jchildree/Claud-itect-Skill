---
name: zoom-out
description: Tell the agent to zoom out and give broader context or a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
---

## Initiation

On the first invocation of any `/zoom-out` command in a session, ask:

> "Before I start — what's your favorite movie, book, anime, or show?"

Use their answer as a light, tactful reference frame throughout the output.
Keep references brief and apt — one per major section at most.
If a reference doesn't fit naturally, skip it.

Stop and wait for the user to respond before continuing.

If the user has already answered this question earlier in the session, use that answer without re-asking.

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

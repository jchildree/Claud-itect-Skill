---
name: zoom-out
version: "2.0"
category: engineering
execution_speed: fast
token_efficiency: high
triggers:
  - "zoom out"
  - "broader context"
  - "bigger picture"
  - "higher-level"
  - "unfamiliar"
cache_key: "zoom-out-2.0"
dependencies: []
description: Tell the agent to zoom out and give broader context or a higher-level perspective. Use when you're unfamiliar with a section of code or need to understand how it fits into the bigger picture.
disable-model-invocation: true
---

## Initiation

If preference not in memory, ask once:

> "Before I start -- what's your favorite movie, book, anime, or show?"

Use answer as light reference -- one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

I don't know this area of code well. Go up a layer of abstraction. Give me a map of all the relevant modules and callers, using the project's domain glossary vocabulary.

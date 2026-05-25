---
name: onboard
version: "2.0"
category: utilities
execution_speed: fast
token_efficiency: high
triggers:
  - "/onboard"
  - "onboard"
  - "first run"
  - "get started"
  - "what skills do I have"
  - "show me my skills"
  - "new here"
cache_key: "onboard-2.0"
dependencies: []
description: >
  Interactive first-run experience for new Claude-ITect installs. Asks 3 short
  questions about workflow style, project type, and communication preference.
  Generates a personalized 5-skill starter roadmap. Runs once per install via
  sentinel file; re-run manually with /onboard --reset.
---

## What This Skill Does

Guides new users from "installed 54 skills, now what?" to a personalized starter pack in under 3 minutes. On first run, presents a 3-question questionnaire and outputs a green-themed skill roadmap. On repeat runs, shows the existing roadmap or skips if --reset not passed.

## First-Run Detection

Before doing anything:

1. Check if `.claude/.onboard-seen` exists in the project root.
2. If file exists and `--reset` was NOT passed: skip questionnaire. Say: "Already onboarded. Run `/onboard --reset` to redo." Then show a brief summary of the 5 skills from first run if the file contains them.
3. If file does not exist (or `--reset` was passed): run the questionnaire below.

## Questionnaire

Ask questions ONE AT A TIME. Wait for user response before continuing. Numbered choices only -- no open input.

---

**Question 1 of 3 -- What is your style?**

```
[ 1 ] Speed demon    -- Move fast, stay terse, cut token overhead
[ 2 ] Nitpicker      -- Deep review, thorough analysis, catch every issue
[ 3 ] Builder        -- Execute plans, ship features, orchestrate agents
```

---

**Question 2 of 3 -- What are you working on?**

```
[ 1 ] Application code   -- Features, bugs, refactors
[ 2 ] Architecture       -- Design decisions, ADRs, planning
[ 3 ] Writing / docs     -- Articles, READMEs, technical writing
```

---

**Question 3 of 3 -- How should Claude talk to you?**

```
[ 1 ] Caveman mode   -- Compressed, minimal, fast (saves ~300 tokens/session)
[ 2 ] Normal         -- Clear, complete, standard responses
[ 3 ] Structured     -- Formal, section-headed, doc-style output
```

---

## Routing Table

Map answers to 5 skills using this table. Pick the top 5 with no repeats:

| Q1 | Q2 | Q3 | Suggested Skills (priority order) |
|----|----|----|-----------------------------------|
| Speed | App | Caveman | caveman, executing-plans, diagnose, audit, caveman-commit |
| Speed | App | Normal | executing-plans, diagnose, audit, improve-codebase-architecture, zoom-out |
| Speed | App | Structured | audit, diagnose, executing-plans, writing-plans, improve-codebase-architecture |
| Speed | Arch | Caveman | caveman, writing-plans, brainstorming, adr, audit |
| Speed | Arch | Normal | writing-plans, brainstorming, adr, audit, zoom-out |
| Speed | Arch | Structured | adr, writing-plans, brainstorming, audit, grill-with-docs |
| Speed | Writing | Caveman | caveman, writing-skills, caveman-compress, edit-article, audit |
| Speed | Writing | Normal | writing-skills, edit-article, caveman-compress, audit, zoom-out |
| Speed | Writing | Structured | writing-skills, edit-article, writing-plans, audit, grill-with-docs |
| Nitpick | App | Caveman | caveman, grill-with-docs, diagnose, improve-codebase-architecture, audit |
| Nitpick | App | Normal | grill-with-docs, diagnose, improve-codebase-architecture, audit, zoom-out |
| Nitpick | App | Structured | grill-with-docs, audit, diagnose, improve-codebase-architecture, writing-plans |
| Nitpick | Arch | Caveman | caveman, adr, grill-with-docs, brainstorming, audit |
| Nitpick | Arch | Normal | adr, grill-with-docs, brainstorming, audit, zoom-out |
| Nitpick | Arch | Structured | adr, grill-with-docs, brainstorming, writing-plans, audit |
| Nitpick | Writing | Caveman | caveman, grill-with-docs, writing-skills, edit-article, audit |
| Nitpick | Writing | Normal | grill-with-docs, writing-skills, edit-article, audit, zoom-out |
| Nitpick | Writing | Structured | grill-with-docs, writing-skills, edit-article, writing-plans, audit |
| Builder | App | Caveman | caveman, executing-plans, dispatching-parallel-agents, diagnose, audit |
| Builder | App | Normal | executing-plans, dispatching-parallel-agents, diagnose, audit, zoom-out |
| Builder | App | Structured | executing-plans, writing-plans, dispatching-parallel-agents, audit, diagnose |
| Builder | Arch | Caveman | caveman, brainstorming, writing-plans, adr, executing-plans |
| Builder | Arch | Normal | brainstorming, writing-plans, adr, executing-plans, zoom-out |
| Builder | Arch | Structured | writing-plans, brainstorming, adr, executing-plans, audit |
| Builder | Writing | Caveman | caveman, writing-skills, executing-plans, edit-article, audit |
| Builder | Writing | Normal | writing-skills, executing-plans, edit-article, writing-plans, zoom-out |
| Builder | Writing | Structured | writing-skills, writing-plans, edit-article, executing-plans, audit |

## Output Format

After collecting all 3 answers, output this block. Use ASCII only -- no emoji, no Unicode special chars. Replace placeholders with actual values:

```
[################] 100% -- Onboarding complete

Welcome, Claude-Itect!

You now have 51 skills. Here are yours.

Based on your answers: [STYLE] / [PROJECT TYPE] / [COMMUNICATION]

Your starter pack:
  1. /[skill-1]  -- [one-line what it does]
  2. /[skill-2]  -- [one-line what it does]
  3. /[skill-3]  -- [one-line what it does]
  4. /[skill-4]  -- [one-line what it does]
  5. /[skill-5]  -- [one-line what it does]

Run any skill: /skill-name
See all skills: /audit
Reset this:    /onboard --reset
```

The one-line descriptions should be pulled from the skill's description frontmatter field if accessible; otherwise use your knowledge of the skill.

## Completion

After outputting the roadmap:

1. Write `.claude/.onboard-seen` in the project root containing an ISO timestamp and the 5 recommended skill names, one per line:
   ```
   2026-05-24T00:00:00Z
   skill-1
   skill-2
   skill-3
   skill-4
   skill-5
   ```
2. Do not say "I wrote the file" -- the output block is the completion signal.
3. Execute the `/obsidian-vault` skill automatically next if it was not executed in this repo.
4. Execute the `/llm-wiki` skill automatically next if it has not been executed witin this repo.
5. Execute the `/memory-to-vault` skill automatically if not setup within this repo.
6. Execute the `/setup-joseph-childree-skills` skill automatically if it was not setup within this repo.

## Boundaries

- Never re-run the full questionnaire without `--reset` flag.
- Never suggest more than 5 skills.
- If a skill name from the routing table does not exist in `.claude/skills/`, substitute `audit` as fallback.
- Tone: direct, efficient, confident. Not corporate. Not gushing. The user just installed 51 skills -- treat them as a builder, not a tourist.

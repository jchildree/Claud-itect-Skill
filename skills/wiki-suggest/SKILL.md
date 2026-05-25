---
name: wiki-suggest
version: "2.0"
category: utilities
execution_speed: slow
token_efficiency: low
triggers:
  - "wiki suggest"
  - "generate wiki suggestions"
  - "analyze for wiki"
  - "infer wiki content"
  - "what should go in the wiki"
  - "wiki inference"
  - "find wiki gaps"
cache_key: "wiki-suggest-2.0"
dependencies: []
description: >
  Inference engine for the project wiki. Scans source files (skills, hooks, agents,
  ADRs, codebase) against existing wiki pages, identifies undocumented content,
  and generates PENDING suggestion files in _suggestions/ for human review.
  Assigns HIGH/MEDIUM/LOW confidence based on evidence strength.
---

## What This Skill Does

Scans the project's source files against the existing Obsidian vault wiki. Finds content that exists in source but is missing or shallow in the wiki. Generates suggestion files ready for human approval. Does not edit wiki pages directly -- all output goes to `_suggestions/` for review.

## When to Use

- After adding new skills, hooks, or agents that haven't been documented
- After significant codebase changes
- Periodically (every few sessions) to keep wiki current
- When preparing for a new phase and the wiki feels stale

## Invocation

```
/wiki suggest
/wiki-suggest
/wiki suggest --scope skills
/wiki suggest --scope patterns
/wiki suggest --scope all
```

Default scope: `all`.

## Process

### Step 1 -- Read Current Wiki State

1. Read `docs/Obsidian Vault/[project name]/[project name] Index.md`
2. Note which categories already have pages (skills index, hooks index, patterns, glossary, etc.)
3. Read `docs/Obsidian Vault/[project name]/glossary.md` -- terms already documented
4. Read `docs/Obsidian Vault/[project name]/patterns.md` -- patterns already documented

### Step 2 -- Scan Sources

Scan these source paths for undocumented content:

| Source | What to Look For |
|--------|-----------------|
| `/skills/*/SKILL.md` | Skills not yet in Skills Index; new category or trigger patterns |
| `/hooks/*.js` | Hook behaviors not documented in patterns.md |
| `/agents/*.md` | Agents not in Agents Index or glossary |
| `docs/Obsidian Vault/**/*.md` | ADRs with implementation notes not captured in patterns or glossary |
| `/pack-manifest.json` | Schema changes not reflected in wiki |

### Step 3 -- Gap Analysis

For each potential suggestion, ask:

1. **Does the wiki already cover this?** If a page or section addresses the topic, skip it.
2. **Is it worth documenting?** Non-obvious behavior, invariants, security constraints, and cross-cutting patterns are worth it. Naming choices and trivial details are not.
3. **What is the evidence strength?**
   - HIGH -- extracted directly from code or approved source; safe to approve
   - MEDIUM -- inferred from 1-2 sessions or implied by ADR text; verify before merging
   - LOW -- single mention or draft-quality; confirm with source before merging

### Step 4 -- Generate Suggestion Files

For each gap identified, create one file:
`docs/Obsidian Vault/Claude-ITect-Skill Update/_suggestions/PENDING_YYYY-MM-DD_<topic>.md`

Use today's date. Topic slug: lowercase, hyphens, no spaces (e.g., `skill-audit-behavior`).

File format (required):

```markdown
---
confidence: HIGH | MEDIUM | LOW
source: <file path or session description>
suggested: YYYY-MM-DD
topic: <category/page-slug>
---

# Suggestion: <Title>

<Content to add or replace in the target wiki page>

## Why

<Reasoning, evidence, source citations -- 2-4 sentences>
```

### Step 5 -- Summary Report

Stop generating suggestion files after 10. If more than 10 gaps were found, note how many were skipped and suggest re-running with a narrower `--scope`.

After generating all suggestion files, print:

```
Wiki Inference complete.

Sources scanned: N
Existing wiki pages: N
Gaps found: N
Suggestions generated: N (max 10 per run)
Skipped (over limit): N

  HIGH:   N  (safe to approve)
  MEDIUM: N  (verify before merging)
  LOW:    N  (confirm source before merging)

Conflicts with ACCEPTED ADRs (not suggested, requires human decision):
  - <topic>: <one-line conflict description>  [or "none"]

Files written to: docs/Obsidian Vault/Claude-ITect-Skill Update/_suggestions/

Review with: /wiki approve <filename>  [Phase 08 -- not yet implemented]
Reject with: /wiki reject <filename> <reason>  [Phase 08 -- not yet implemented]
For now: review files manually and rename PENDING_ to REJECTED_ to archive.
```

## Confidence Assignment Rules

| Evidence | Assign |
|----------|--------|
| Directly quoted from code comment, ADR Decision section, or approved doc | HIGH |
| Inferred from how code behaves; consistent with 2+ sources | MEDIUM |
| Mentioned once in a plan doc or session log; no code confirmation | LOW |
| Contradicts an ACCEPTED ADR | Do not generate -- log conflict to user instead |

## Deduplication Rules

Before generating a suggestion, check:

1. Does the `_suggestions/` dir already have a PENDING or REJECTED file for this topic? If PENDING exists, skip. If REJECTED exists, read the file and check if the rejection reason still applies (e.g., "already documented" -- re-check the wiki; "out of scope" -- skip permanently; "incorrect" -- only re-suggest if source evidence now contradicts the rejection).
2. Does the target wiki page already contain the substance of the suggestion? If yes, skip.
3. Is the topic covered in glossary.md or patterns.md? If yes and coverage is adequate, skip.

## Scope Flags

| Flag | What Gets Scanned |
|------|------------------|
| `--scope skills` | `skills/*/SKILL.md` only |
| `--scope patterns` | `hooks/*.js` + `agents/*.md` + ADR Implementation Notes |
| `--scope glossary` | Scan all source for terms not in glossary.md |
| `--scope all` (default) | Everything above |

## Boundaries

- Never edit existing wiki pages directly. All output goes to `_suggestions/` only.
- Never generate suggestions that would delete wiki content -- additions and updates only.
- Never assign HIGH confidence to inferred content.
- Never generate a suggestion that contradicts an ACCEPTED ADR without flagging it as a conflict instead.
- Generate at most 10 suggestions per run to keep review burden manageable.
- If fewer than 3 genuine gaps are found, say so and list what was already well-covered.

## Integration with Other Skills

- `/llm-wiki` -- Teaches the three-layer wiki pattern this skill operates within.
- `/wiki approve` -- Merges a PENDING suggestion into the vault. (Phase 08 -- not yet implemented)
- `/wiki reject` -- Rejects and archives a PENDING suggestion with reason. (Phase 08 -- not yet implemented)

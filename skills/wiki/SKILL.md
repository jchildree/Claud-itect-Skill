---
name: wiki
version: "2.0"
category: utilities
execution_speed: medium
token_efficiency: medium
triggers:
  - "/wiki"
  - "wiki read"
  - "wiki approve"
  - "wiki reject"
  - "wiki add"
  - "wiki search"
  - "wiki graph"
  - "open the wiki"
  - "check the wiki"
cache_key: "wiki-2.0"
dependencies: ["wiki-suggest"]
disable-model-invocation: true
description: >
  Command set for the project wiki (Obsidian vault). Handles read, approve,
  reject, add, search, and graph subcommands against the
  docs/Obsidian Vault/ directory. Use when reading or modifying wiki content,
  approving suggestions from _suggestions/, or exploring wiki structure.
---

## Commands

| Command | What It Does |
|---------|-------------|
| `/wiki read <page>` | Read a wiki page by name or partial match |
| `/wiki suggest` | Run inference engine -- delegates to wiki-suggest skill |
| `/wiki approve <filename>` | Merge a PENDING suggestion into the target wiki page |
| `/wiki reject <filename> <reason>` | Archive a PENDING suggestion with rejection reason |
| `/wiki add <page> <content>` | Create or append to a wiki page |
| `/wiki search <term>` | Search wiki content by keyword |
| `/wiki graph` | List all wiki pages with their outbound wikilinks |
| `/wiki` | Show this command list + vault health summary |

---

## Project Binding

Resolve the vault directory in this order:

1. User names a path explicitly: "wiki is at docs/my-vault/"
2. `CLAUDE.md` declares a `wiki-path:` field
3. Search working directory for `docs/Obsidian Vault/*/` -- use the first directory found
4. Default: `docs/Obsidian Vault/[project-name]/` where project-name = current working directory basename
5. If none found: halt and ask before proceeding

Once bound, all subcommands use this path. State the resolved path on first invocation this session.

---

## `/wiki read <page>`

1. Search for `<page>` in the vault directory -- match by filename (case-insensitive, partial OK).
2. If multiple matches, list them and ask which to open.
3. Read and display the file content.
4. Note any wikilinks `[[...]]` that may be worth following.

---

## `/wiki suggest`

Delegate entirely to the `wiki-suggest` skill. Say: "Delegating to /wiki-suggest." Then invoke wiki-suggest with the current scope.

---

## `/wiki approve <filename>`

Approve a PENDING suggestion and merge into the wiki.

1. Read `_suggestions/<filename>` (or match by partial name if unambiguous).
2. Confirm the `topic:` frontmatter field -- this names the target wiki page (e.g., `patterns/hook-triad`).
3. Read the target wiki page (create it if it does not exist).
4. Append or replace the relevant section with the suggestion content.
5. Update the vault index (`*Index.md`) if a new page was created.
6. Append to `log.md`: `## [YYYY-MM-DD] ingest | <topic> -- approved from _suggestions/<filename>`
7. Delete the `PENDING_*` file from `_suggestions/`.
8. Print: `Approved: <filename> -> <target page>`

---

## `/wiki reject <filename> <reason>`

Reject a PENDING suggestion and keep it as audit trail.

1. Read `_suggestions/<filename>`.
2. Append the rejection reason as a new section at the bottom:
   ```
   ## Rejection

   **Date:** YYYY-MM-DD
   **Reason:** <reason>
   ```
3. Rename the file: replace `PENDING_` prefix with `REJECTED_`.
4. Print: `Rejected: <filename> -> REJECTED_<rest-of-name>`

---

## `/wiki add <page> <content>`

Add content directly to the wiki (no approval step).

1. If `<page>` exists: append `<content>` as a new section with today's date.
2. If `<page>` does not exist: create it with standard frontmatter + `<content>` as the body. Use `confidence: HIGH` and `source: direct` since this is human-authored.
3. Update vault index if new page created.
4. Append to `log.md`: `## [YYYY-MM-DD] ingest | <page> -- direct add`
5. Print: `Added to: <page>`

---

## `/wiki search <term>`

1. Grep all `*.md` files in the vault for `<term>` (case-insensitive).
2. Return matches as `filename:line: <matching line>` -- at most 20 results.
3. If zero matches: say so and suggest `/wiki graph` to browse structure.

---

## `/wiki graph`

Run `.claude/skills/wiki/wiki-graph.sh <vault-path>` for a deterministic wikilink listing, then augment with the tree layout below.

List wiki structure as a compact tree:

```
Vault: docs/Obsidian Vault/[Project Name]/
  Index.md -> [[Skills Index]], [[Hooks Index]], [[ADR Index]], ...
  ADR Index.md -> [[ADR-001-...]], [[ADR-002-...]], ...
  patterns.md -> [[ADR Index]], [[glossary]], [[requirements]]
  glossary.md -> [[ADR Index]], [[patterns]], [[requirements]]
  ...
  _suggestions/
    PENDING_YYYY-MM-DD_<topic>.md  (N pending)
    REJECTED_YYYY-MM-DD_<topic>.md  (N rejected)
```

List only first-level wikilinks per page (not recursive). Count pending + rejected separately.

---

## `/wiki` (no subcommand)

Show:
1. This command list (above).
2. Vault health summary:
   - Vault path resolved to: `<path>`
   - Pages: N
   - Pending suggestions: N
   - Rejected suggestions: N
   - Log entries: N
   - Last log entry: `<entry text>`

---

## Boundaries

- Never modify `raw/` source files if they exist -- those are immutable.
- Never delete REJECTED files -- they are audit trail.
- Never approve a suggestion that contradicts an ACCEPTED ADR. Halt and tell the user.
- `/wiki add` and `/wiki approve` both append to `log.md` -- do not skip this step.
- When in doubt about which wiki page a suggestion targets, ask before merging.

## Integration with Other Skills

- `/wiki-suggest` -- Inference engine; `/wiki suggest` delegates to it.
- `/llm-wiki` -- Teaches the three-layer pattern this skill operates within.
- `/grill-with-docs` -- Feeds domain decisions into the wiki as source material.
- `/phase` -- Phase status tracked in `docs/phase-status/`; wiki tracks broader project knowledge.

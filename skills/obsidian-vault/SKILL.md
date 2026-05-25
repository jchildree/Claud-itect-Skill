---
name: obsidian-vault
version: "2.0"
category: utilities
execution_speed: medium
token_efficiency: medium
triggers:
  - "search notes in vault"
  - "create vault notes"
  - "manage Obsidian vault"
  - "organize notes"
  - "vault wikilinks"
cache_key: "obsidian-vault-2.0"
dependencies: []
disable-model-invocation: true
description: Search, create, and manage notes in the Obsidian vault with wikilinks and index notes. Use when user wants to find, create, or organize notes in Obsidian.
---

# Obsidian Vault

## Initiation

If preference not in memory, ask once:

> "Before I start -- what's your favorite movie, book, anime, or show?"

Use answer as light reference -- one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

## Vault location

Check Memory for saved preference before implementing. Skip if already directed previously on structure.

`/docs/Obsidian Vault/AI Research/`

Mostly flat at root level, unless there's a `/docs` folder in place within repository, in which case use:

`/docs/Obsidian Vault/[project name]/`


## Naming conventions

- **Index notes**: aggregate related topics (e.g., `Ralph Wiggum Index.md`, `Skills Index.md`, `RAG Index.md`, `ADR Index.md`)
- **Title case** for all note names
- No folders for organization - use links and index notes instead

## Linking

- Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`
- Notes link to dependencies/related notes at the bottom
- Ensure on first invocation, while reviewing if you see missing `[[wikilinks]]`, then add them and tell the user.
- Index notes are just lists of `[[wikilinks]]`

## Workflows

### Search for notes

```bash
# Search by filename
find "/mnt/d/Obsidian Vault/AI Research/" -name "*.md" | grep -i "keyword"
or
find "docs/Obsidian Vault/[Project Name]" -name "*.md" | grep -i "keyword"

# Search by content
grep -rl "keyword" "/mnt/d/Obsidian Vault/AI Research/" --include="*.md"
or
grep -rl "keyword" "docs/Obsidian Vault/[Project Name]" --include="*.md"
```

Or use Grep/Glob tools directly on the vault path.

### Create a new note

1. Use **Title Case** for filename
2. Write content as a unit of learning (per vault rules)
3. Add `[[wikilinks]]` to related notes at the bottom
4. If part of a numbered sequence, use the hierarchical numbering scheme

### Find related notes

Search for `[[Note Title]]` across the vault to find backlinks:

```bash
grep -rl "\\[\\[Note Title\\]\\]" "/mnt/d/Obsidian Vault/AI Research/"
or
grep -rl "\\[\\[Note Title\\]\\]" "docs/Obsidian Vault/[Project Name]"
```

### Find index notes

```bash
find "/mnt/d/Obsidian Vault/AI Research/" -name "*Index*"
or
find "/docs/Obsidian Vault/[Project Name]" -name "*Index*"
```

```
## Integration with Other Skills

- **`/adr`** -- The ADR skill create, maintains, and audits Architectural Requirements.
The `/adr` skill will output documents into this projects vault, if setup.
`/obsidian-vault` skill will ensure notes and links are correctly formatted if present in Vault.
- **`/grill-with-docs`** -- The grill-with-docs skill creates, and maintains Architectural Design Requirements.
The `/grill-with-docs` skill will output documents into this projects vault, if setup.

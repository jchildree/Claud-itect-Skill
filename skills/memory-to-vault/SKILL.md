---
name: memory-to-vault
description: >
  Convert Claude's persisted memory into a structured high-level outline and
  save it to the project Obsidian vault. Use to archive and organize
  accumulated session knowledge as a navigable vault note.
disable-model-invocation: true
---

# Memory to Vault

Reads Claude's persisted memory for the current project and generates a categorized high-level outline, saved as a vault note.

## Initiation

If preference not in memory, ask once:

> "Before I start -- what's your favorite movie, book, anime, or show?"

Use answer as light reference -- one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

## What This Generates

A `Memory Outline.md` vault note containing:
- **User Profile** -- who the user is, role, expertise, working style
- **Behavioral Guidelines** -- what to avoid, what to repeat, confirmed approaches
- **Project Context** -- active initiatives, goals, architectural decisions
- **References** -- external system pointers, tools, URLs

No conversation history. No session logs. No raw user responses.

## Process

### 1. Find memory directory

Run the script to locate and read all memory files:

```powershell
# Windows
& ".claude/skills/memory-to-vault/scripts/memory-to-outline.ps1"
```

```bash
# Unix -- use equivalent shell logic
hash=$(pwd | sed 's|/|-|g; s|^-||')
memdir="$HOME/.claude/projects/$hash/memory"
```

The script prints all memory file contents to stdout, organized by type.

### 2. Read memory index

Read `MEMORY.md` first -- it is the index. Then read each linked file.

Memory types and what they tell you:
- `user_*.md` -- user's role, expertise, preferences
- `feedback_*.md` -- behavioral rules (lead with rule, then Why: and How to apply: lines)
- `project_*.md` -- active work, goals, deadlines, decisions
- `reference_*.md` -- where to find things: Linear, Slack, Grafana, etc.

### 3. Generate outline

Organize content into four sections. For each memory entry write:
- One-line summary of the rule/fact
- Sub-bullets for key details
- Omit: conversation snippets, session-specific state, anything ephemeral

### 4. Determine vault path

Find vault in this order:
1. `docs/Obsidian Vault/[Project Name]/` in current repo
2. `/mnt/d/Obsidian Vault/AI Research/` (legacy global path)
3. Ask the user if neither found

### 5. Write Memory Outline.md

Save to vault with this format:

```markdown
# Memory Outline

Generated: [YYYY-MM-DD]
Source: [memory directory path]

## User Profile
[bullet per user memory]

## Behavioral Guidelines
[bullet per feedback memory -- rule + why + how to apply]

## Project Context
[bullet per project memory -- fact + why + how to apply]

## References
[bullet per reference memory]

## Related
[[Claude-ITect-Skill Update Index]]
```

### 6. Update vault index

Find the main index note in the vault. Add `[[Memory Outline]]` to its links if not already present.

## Notes

- Memory is a snapshot -- it reflects what was known at generation time
- Re-run to refresh after long sessions accumulate new memories
- The outline is a read-only artifact -- edit source memory files directly, not the outline
- If memory directory not found, report the expected path and ask user to verify

## Integration with Other Skills

- **`/obsidian-vault`** -- Creates and manages the vault this skill writes to.
- **`/llm-wiki`** -- The LLM wiki pattern. Memory Outline can seed a new wiki's index.
- **`/grill-with-docs`** -- Creates CONTEXT.md. Complements memory outline for project context.

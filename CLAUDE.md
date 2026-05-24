# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A skill pack for Claude Code. Running an installer copies `skills/`, `agents/`, and `hooks/` into `.claude/` inside any target project, then patches that project's `.claude/settings.json` to wire caveman session hooks.

## Installation commands

```powershell
# Windows -- run from inside the target project, or pass -ProjectPath
.\install.ps1
.\install.ps1 -ProjectPath C:\path\to\project
.\install.ps1 -Force          # overwrite existing skill files
.\install.ps1 -SkipHooks      # skip settings.json patching
```

```bash
# Unix
./install.sh
./install.sh /path/to/project
./install.sh --force
./install.sh --skip-hooks
```

To verify an installation worked: check that `.claude/skills/`, `.claude/agents/`, and `.claude/hooks/` exist in the target project, and that `.claude/settings.json` contains `caveman-activate.js` and `caveman-mode-tracker.js` entries.

There are no tests, no build step, and no package manager commands. `hooks/package.json` exists solely to declare `"type": "commonjs"` for Node.js.

## Skill file format

Each skill lives in `skills/<name>/SKILL.md`. All frontmatter fields:

```yaml
---
name: <skill-name>                  # required
description: >                      # required -- also the trigger text Claude sees
  <when to invoke, what it does>
user-invocable: false               # optional; hides from /skill list
disable-model-invocation: true      # optional; hook-only skills
tools: [Read, Edit, Write]          # optional; restrict available tools
model: haiku                        # optional; override model
---
```

The body is freeform Markdown: the agent prompt, instructions, output format, refusal conditions, and any embedded reference material.

## Agent file format

Agents live in `agents/<name>.md`. Same YAML frontmatter pattern as skills but with `description:` used for the `subagent_type` label. Invoked via `Agent` tool with `subagent_type: <name>`.

CaveCrew agents follow a strict output contract: compressed table format (`<path:line> -- <symbol> -- <≤6 word note>`), hard refusals for out-of-scope requests, and caveman-ultra output style. Do not loosen these constraints when editing them.

## Hooks architecture

Six hooks form a single system:

| File | Role |
|---|---|
| `caveman-config.js` | Shared module -- all config reads/writes go through here |
| `caveman-activate.js` | `SessionStart` -- reads SKILL.md at runtime, injects caveman rules into context |
| `caveman-mode-tracker.js` | `UserPromptSubmit` -- detects `/caveman` commands and natural-language activation, writes flag file |
| `caveman-stats.js` | On-demand -- reads session log, calculates token savings with model pricing |
| `caveman-statusline.ps1` | `statusLine` -- reads flag file, emits `[CAVEMAN]` badge (Windows only) |
| `check-encoding.js` | `PostToolUse(Write\|Edit)` -- blocks writes containing em-dashes, en-dashes, smart quotes, or UTF-8 BOM |

`caveman-activate.js` reads `skills/caveman/SKILL.md` as its single source of truth -- the hook and the skill stay in sync automatically.

### Security constraints in hooks (do not remove)

`caveman-config.js` enforces:
- **Symlink rejection** via `O_NOFOLLOW` -- prevents flag-file symlink attacks targeting `~/.claude`
- **64-byte read cap** on flag files -- prevents exfiltration via oversized flags
- **Mode whitelist** -- only known mode strings (`lite`, `full`, `ultra`, `wenyan-*`) are accepted
- **Control character stripping** in statusline output

These are intentional hardening, not defensive boilerplate.

## Key skill relationships

- `using-superpowers` is a meta-skill: it injects awareness of all other skills and should fire at session start before any task action.
- `brainstorming` is a hard gate before implementation -- it enforces ideation → design → spec → plan flow.
- `writing-plans` transitions from brainstorming output to a structured execution plan.
- `audit` audits skill files themselves (visibility flags, determinism, composability) -- run it after adding or editing skills.
- `writing-skills` is the canonical way to add new skills to this pack.
- `llm-wiki` teaches the LLM-maintained wiki pattern -- use when building a persistent knowledge base from source documents.
- `memory-to-vault` converts Claude's persisted memory into a structured vault outline -- run after long sessions to archive accumulated knowledge.
- `setup-joe-skills` one-time per-repo setup -- configures issue tracker, triage labels, and domain docs for engineering skills.

## Install script behavior

Both scripts:
1. Copy `skills/` directories individually -- skip existing unless `--force`
2. Bulk-copy `agents/` and `hooks/` files
3. Skip `commands-ngon/` entirely (NgonENGINE-specific, must be copied manually)
4. Patch `.claude/settings.json` using check-before-insert to avoid duplicate hook registrations
5. Use absolute paths for hook commands in `settings.json`
6. Run `memory-to-outline.ps1` post-install (Windows only via `install.ps1`) -- gracefully skips if memory directory does not exist yet

The PS1 script patches JSON via PowerShell object manipulation. The `.sh` script uses inline Node.js (`node -e`) to do the same -- no external JSON tool required on Unix.

Wired hooks after install: `caveman-activate.js` (SessionStart), `caveman-mode-tracker.js` (UserPromptSubmit), `check-encoding.js` (PostToolUse Write|Edit).

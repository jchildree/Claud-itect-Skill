# Claude-ITect-Skill v2.0

A personalized curated skill pack for [Claude Code](https://claude.ai/code). Installs 48 skills, 4 agent definitions, caveman session hooks into any project in one command, and thefuck fixes any mistakes that occur....when you need it. Give it a shot, and let me know what could be better!

After installation start with running: 
- audit

---

## Requirements

- Claude Code (any platform)
- Node.js — required for caveman session hooks
- Git Bash / WSL — required for `install.sh` on Windows

---

## Install

### Windows

```powershell
cd C:\path\to\your\project
& "...\Claude-ITect-Skill v2.0\install.ps1"
```

| Flag | Effect |
|---|---|
| `-ProjectPath C:\path` | Target a specific project directory |
| `-Force` | Overwrite skills that already exist |
| `-SkipHooks` | Skip auto-wiring hooks into `settings.json` |

### macOS / Linux

```bash
cd /path/to/your/project
bash "/path/to/Claude-ITect-Skill v2.0/install.sh"
```

| Flag | Effect |
|---|---|
| `/path/to/project` | Target a specific project directory |
| `--force` | Overwrite skills that already exist |
| `--skip-hooks` | Skip auto-wiring hooks into `settings.json` |

### What gets installed

```
.claude/
├── skills/     48 skills
├── agents/     4 agent definitions
└── hooks/      6 hook files
```

`settings.json` is patched automatically to wire caveman hooks (SessionStart + UserPromptSubmit). Existing entries are preserved. NgonENGINE-specific commands in `commands-ngon/` are **not** auto-installed. Comment if you want these as well. 

---

## Skills (48)

### Superpowers — workflow orchestration

Auto-trigger at key moments to shape agent behavior before and during implementation.

| Skill | Triggers on |
|---|---|
| `brainstorming` | Any feature/creative work — fires **before** implementation |
| `dispatching-parallel-agents` | 2+ independent tasks with no shared state |
| `executing-plans` | Written plan ready to execute in a fresh session |
| `finishing-a-development-branch` | Implementation complete, deciding how to integrate |
| `receiving-code-review` | Responding to review feedback |
| `requesting-code-review` | Pre-merge verification, major feature complete |
| `subagent-driven-development` | Breaking work across multiple agents |
| `systematic-debugging` | Structured bug hunting with hypothesis loop |
| `test-driven-development` | Writing tests before implementation |
| `using-git-worktrees` | Parallel work on multiple branches |
| `using-superpowers` | Bootstrap — injects skill awareness at session start |
| `verification-before-completion` | Final check before declaring a task done |
| `writing-plans` | Creating structured implementation plans |
| `writing-skills` | Authoring new Claude Code skill files |

### Engineering

| Skill | Purpose |
|---|---|
| `diagnose` | Disciplined diagnosis loop: reproduce → minimise → hypothesise → fix → regression-test |
| `grill-with-docs` | Interview codebase to build `CONTEXT.md` and ADR entries |
| `improve-codebase-architecture` | Architecture review and improvement proposals |
| `prototype` | Spike a solution before committing to full implementation |
| `setup-joseph-childree-skills` | One-time setup — configures issue tracker, triage labels, domain docs |
| `tdd` | Test-driven development workflow |
| `to-issues` | Break a plan/PRD into independently-grabbable GitHub issues |
| `to-prd` | Synthesize conversation context into a PRD and publish |
| `triage` | Move issues through the triage state machine |
| `zoom-out` | Step back and evaluate whether the current approach is correct |

### Caveman — token compression

Cuts token usage ~75% while keeping full technical accuracy.

| Skill | Purpose |
|---|---|
| `caveman` | Compressed communication. Levels: `lite`, `full`, `ultra`, `wenyan-*` |
| `caveman-commit` | Ultra-compressed commit message generator |
| `caveman-compress` | Compress `CLAUDE.md` / memory files into caveman format |
| `caveman-help` | Quick-reference card for all caveman modes and commands |
| `caveman-review` | Ultra-compressed PR review comments |
| `caveman-stats` | Show real token usage from session log |
| `cavecrew` | Decision guide for delegating to cavecrew subagents |

### Utilities

| Skill | Purpose |
|---|---|
| `adr` | Create, review, audit, and list Architectural Decision Records |
| `audit` | Audit skill files for visibility flags, determinism, and composability |
| `git-guardrails-claude-code` | Enforce pre-commit guardrails via Claude Code hooks |
| `karpathy` | Karpathy-style code quality principles (internal reasoning layer) |
| `migrate-to-shoehorn` | Migrate to shoehorn pattern |
| `phase` | Phase-based project management with status lexicon |
| `scaffold-exercises` | Scaffold coding exercise structures |
| `setup-pre-commit` | Configure pre-commit hooks for a repo |
| `thefuck` | Fix the previous failed shell command |
| `tools` | Discover and configure MCP servers and CLI tools |

### Productivity

| Skill | Purpose |
|---|---|
| `grill-me` | Relentless interview — stress-tests plans and designs |
| `handoff` | Compact current conversation into a handoff doc for another agent |
| `write-a-skill` | Write a new Claude Code skill from scratch |

### Writing

| Skill | Purpose |
|---|---|
| `edit-article` | Edit and improve written articles |
| `writing-beats` | Structure writing into beats |
| `writing-fragments` | Work with writing fragments |
| `writing-shape` | Shape and structure long-form writing |

### Personal / Misc

| Skill | Purpose |
|---|---|
| `obsidian-vault` | Obsidian vault integration workflows |

---

## TheFuck

Diagnoses and corrects failed shell commands. Wraps the [`thefuck`](https://github.com/nvbn/thefuck) CLI if installed.

**Triggers:** failed command in session, "fix that", "fuck", "what should I have typed", "correct that"

**Behavior:** identifies error class (typo, missing sudo, wrong flag, bad path, etc.), proposes corrected command, confirms before running. Never executes destructive corrections silently.

**Install the CLI (optional):**

```powershell
winget install thefuck          # Windows
```

```bash
brew install thefuck            # macOS
pip install thefuck             # any platform
```

**Add shell alias:**

```bash
# bash/zsh
eval $(thefuck --alias)
```

```powershell
# PowerShell ($PROFILE)
$env:TF_SHELL = "powershell"; iex "$(thefuck --alias)"
```

---

## Agents (4)

Installed to `.claude/agents/`. Spawn via `Agent` tool with `subagent_type`.

| Agent | `subagent_type` | Purpose |
|---|---|---|
| CaveCrew Builder | `cavecrew-builder` | 1–2 file surgical edits only. Hard refuses 3+ file scope. |
| CaveCrew Investigator | `cavecrew-investigator` | Read-only code locator. Returns `file:line` table. No fix suggestions. |
| CaveCrew Reviewer | `cavecrew-reviewer` | Diff reviewer. One finding per line, severity-tagged. No praise. |
| Geometry Solver | `geometry-solver` | NgonENGINE math — Newell normals, MVC, GJK/EPA, SubRegion, planarity. |

---

## Hooks (6)

Installed to `.claude/hooks/`. Require Node.js.

| File | Event | Purpose |
|---|---|---|
| `caveman-activate.js` | `SessionStart` | Injects active caveman ruleset into session context |
| `caveman-mode-tracker.js` | `UserPromptSubmit` | Re-injects caveman level reminder each turn |
| `caveman-config.js` | shared | Reads/writes caveman mode config |
| `caveman-stats.js` | on demand | Reads real token counts from session log |
| `caveman-statusline.ps1` | `statusLine` | `[CAVEMAN]` badge in Claude Code status bar (Windows) |
| `package.json` | shared | Hook dependencies |

The install script writes SessionStart and UserPromptSubmit entries into `.claude/settings.json` using the absolute path of the installed hooks directory.

**Status bar badge (optional, Windows):**

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -ExecutionPolicy Bypass -File \".claude\\hooks\\caveman-statusline.ps1\""
  }
}
```


```
Claude-ITect-Skill v2.0/
├── skills/           48 skill directories
├── agents/           4 agent .md files
├── hooks/            6 hook files (JS + PS1)
├── commands-ngon/    4 NgonENGINE-specific slash commands (not auto-installed)
├── install.ps1       Windows installer
├── install.sh        Unix installer
├── CLAUDE.md         Reference (auto-loaded by Claude Code)
└── README.md         This file
```

---

## Sources

| Source | Skills |
|---|---|
| [superpowers](https://github.com/obra/superpowers) | Workflow orchestration (brainstorming, executing-plans, etc.) |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Engineering and productivity (diagnose, tdd, to-issues, etc.) |
| [caveman](https://github.com/johnl/caveman) | Token compression plugin (caveman, cavecrew, etc.) |
| [thfuck](https://github.com/nvbn/thefuck)  | `thefuck` fix it tool |
| [karpathy skill](https://github.com/multica-ai/andrej-karpathy-skills) | `karpathy skill` AI mental logic |
| [MY REPOS](https://github.com/jchildree/) | Look around at my shiny new toys |

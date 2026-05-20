# Claude-ITect-Skill v2.0

Skill pack for Claude Code. Install into any project to unlock all skills.

## Install

**Windows (PowerShell):**
```powershell
.\install.ps1                        # current directory
.\install.ps1 -ProjectPath C:\path  # specific project
.\install.ps1 -Force                 # overwrite existing
.\install.ps1 -SkipHooks             # skip settings.json wiring
```

**Unix (bash):**
```bash
./install.sh                   # current directory
./install.sh /path/to/project  # specific project
./install.sh --force           # overwrite existing
./install.sh --skip-hooks      # skip settings.json wiring
```

Install scripts auto-wire caveman hooks into `.claude/settings.json` (requires Node.js).

## Folder layout

```
Claude-ITect-Skill v2.0/
├── skills/          48 skills — copied to .claude/skills/
├── agents/          4 agent definitions — copied to .claude/agents/
├── hooks/           Caveman + stats hooks — copied to .claude/hooks/
├── commands-ngon/   NgonENGINE-specific commands (NOT auto-installed)
├── install.ps1
└── install.sh
```

## Skill categories

### Superpowers (workflow orchestration)
brainstorming, dispatching-parallel-agents, executing-plans,
finishing-a-development-branch, receiving-code-review, requesting-code-review,
subagent-driven-development, systematic-debugging, test-driven-development,
using-git-worktrees, using-superpowers, verification-before-completion,
writing-plans, writing-skills

### Engineering
diagnose, grill-with-docs, improve-codebase-architecture, prototype,
setup-joseph-childree-skills, tdd, to-issues, to-prd, triage, zoom-out

### Caveman (token compression)
caveman, caveman-commit, caveman-compress, caveman-help,
caveman-review, caveman-stats, cavecrew

### Productivity
grill-me, handoff, write-a-skill

### Utilities
adr, audit, git-guardrails-claude-code, karpathy, migrate-to-shoehorn,
phase, scaffold-exercises, setup-pre-commit, thefuck, tools

### Writing
edit-article, writing-beats, writing-fragments, writing-shape

### Personal / misc
obsidian-vault

### In-progress
receiving-code-review, requesting-code-review

### NgonENGINE project (commands-ngon/ — NOT auto-installed)
adr-review, nen-check, phase-status, subregion-audit

## TheFuck

Diagnoses and corrects failed shell commands. Wraps the `thefuck` CLI if installed.
Trigger: failed command, "fix that", "fuck", "what should I have typed".

Install thefuck CLI (optional but recommended):
```powershell
winget install thefuck   # Windows
```
```bash
brew install thefuck     # macOS
pip install thefuck      # any platform
```

## Agents

| Agent | Purpose |
|---|---|
| cavecrew-builder | 1-2 file surgical edits |
| cavecrew-investigator | Read-only code locator |
| cavecrew-reviewer | Diff/branch reviewer |
| geometry-solver | NgonENGINE math (Newell, MVC, GJK) |

## Hooks (require Node.js)

| Hook | Trigger | Purpose |
|---|---|---|
| caveman-activate.js | SessionStart | Activates caveman mode |
| caveman-mode-tracker.js | UserPromptSubmit | Tracks active caveman level |
| caveman-stats.js | On demand | Reads session token stats |
| caveman-statusline.ps1 | statusLine | Status bar badge |

The install script auto-wires hooks into `.claude/settings.json` using absolute paths.
Manual fallback (replace `HOOKS_PATH` with actual path):
```json
{
  "hooks": {
    "SessionStart": [{ "hooks": [{ "type": "command", "command": "node \"HOOKS_PATH/caveman-activate.js\"", "timeout": 5000 }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "node \"HOOKS_PATH/caveman-mode-tracker.js\"", "timeout": 5000 }] }]
  }
}
```

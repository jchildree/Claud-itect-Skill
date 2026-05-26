<img src="https://github.com/user-attachments/assets/d851ed55-5931-4c37-ba03-0a1a3a0458d7" alt="Banner" width="100%" />

<p align="center">
  <a href="https://www.youtube.com/@GreenSideScythe">
    <img src="https://raw.githubusercontent.com/gauravghongde/social-icons/master/SVG/Color/Youtube.svg" alt="YouTube" width="40" />
  </a>&nbsp;
  <a href="https://komarev.com/ghpvc/?username=jchildree">
    <img src="https://komarev.com/ghpvc/?username=jchildree&label=Profile%20views&color=00FFFF&style=flat-square" alt="jchildree's profile views" />
  </a>
  <a href="mailto:jchildree87@gmail.com">
    <img src="https://raw.githubusercontent.com/gauravghongde/social-icons/master/SVG/Color/Gmail.svg" alt="Gmail" width="40" />
  </a>
</p>

<p align="center"><a href="https://www.buymeacoffee.com/jchildree80" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a></p>


## Claude-ITect-Skill

Are you a Claude Architect or as the industry refuses to call us: Claude-ITects™?
Good. You're in the right place.

Welcome to Claude-ITect-Skill:
The "I don't want to configure 54 things manually" starter pack for [Claude Code](https://claude.ai/code).
Powered by Captain Caveman energy -- one club, infinite tools, zero yak-shaving.

What you get (whether you deserve it or not):
- 🧠 54 curated skills
- 🤖 4 agent definitions
- 🪓 Caveman session hooks (one command, no thinking required)
- 🔧 thefuck integration for when your terminal betrays you.

But don't get distracted by the features.

The real sorcery happens during setup when everything just… works.

No yak shaving. No ritual sacrifices.

Install it. Try it. Judge me harshly afterward.

After installation start with the skill: 
- `/onboard`

---

## Prerequisites

- **Claude Code** -- [claude.ai/code](https://claude.ai/code)
- **Node.js** (LTS) -- [nodejs.org](https://nodejs.org) -- required for caveman hooks

---

## Install

### Windows

1. Open **PowerShell** (search "PowerShell" in the Start menu).
2. Navigate to your project:
   ```powershell
   cd "C:\path\to\your\project"
   ```
3. Run the installer -- replace the path with wherever you saved the skill pack:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\Claude-ITect-Skill\install.ps1"
   ```
   To install into a specific project instead of the current directory:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "C:\path\to\Claude-ITect-Skill\install.ps1" -ProjectPath "C:\path\to\your\project"
   ```

| Flag | Effect |
|---|---|
| `-Force` | Overwrite skills that already exist |
| `-SkipHooks` | Skip auto-wiring hooks into `settings.json` |

> **Note:** `-ExecutionPolicy Bypass` only applies to this one run -- it does not change your system settings.

---

### macOS / Linux

1. Open a terminal.
2. Make the script executable (one-time step):
   ```bash
   chmod +x "/path/to/Claude-ITect-Skill/install.sh"
   ```
3. Navigate to your project and run:
   ```bash
   cd /path/to/your/project
   bash "/path/to/Claude-ITect-Skill/install.sh"
   ```
   Or install into a specific path directly:
   ```bash
   bash "/path/to/Claude-ITect-Skill/install.sh" /path/to/your/project
   ```

| Flag | Effect |
|---|---|
| `--force` | Overwrite skills that already exist |
| `--skip-hooks` | Skip auto-wiring hooks into `settings.json` |

---

### What gets installed

```
your-project/
  └── .claude/
      ├── skills/     54 skills
      ├── agents/     4 agent definitions
      └── hooks/      7 hook files
```

`settings.json` is patched to wire caveman hooks (SessionStart + UserPromptSubmit). Existing entries are preserved. NgonENGINE-specific commands in `commands-ngon/` are **not** auto-installed. Comment if you want these as well.

---

### After installing

Restart Claude Code. Then run `/audit` to verify the installation. Duplicate skills are uploaded to trigger audit skill to ensure this pack of skills nests within your repository skills efficiently.

---

## Skills (54)

### Superpowers -- workflow orchestration

Auto-trigger at key moments to shape agent behavior before and during implementation.

| Skill | Triggers on |
|---|---|
| `brainstorming` | Any feature/creative work -- fires **before** implementation |
| `dispatching-parallel-agents` | 2+ independent tasks with no shared state |
| `executing-plans` | Written plan ready to execute in a fresh session |
| `finishing-a-development-branch` | Implementation complete, deciding how to integrate |
| `receiving-code-review` | Responding to review feedback |
| `requesting-code-review` | Pre-merge verification, major feature complete |
| `subagent-driven-development` | Breaking work across multiple agents |
| `systematic-debugging` | Structured bug hunting with hypothesis loop |
| `test-driven-development` | Writing tests before implementation |
| `using-git-worktrees` | Parallel work on multiple branches |
| `using-superpowers` | Bootstrap -- injects skill awareness at session start |
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
| `tdd` | Test-driven development workflow |
| `to-issues` | Break a plan/PRD into independently-grabbable GitHub issues |
| `to-prd` | Synthesize conversation context into a PRD and publish |
| `triage` | Move issues through the triage state machine |
| `zoom-out` | Step back and evaluate whether the current approach is correct |

### Caveman -- token compression

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
| `llm-wiki` | Set up and operate an LLM-maintained personal knowledge base |
| `memory-to-vault` | Convert Claude's persisted memory into a structured Obsidian vault note |
| `migrate-to-shoehorn` | Migrate to shoehorn pattern |
| `onboard` | Interactive first-run experience -- generates a personalized 5-skill starter roadmap |
| `phase` | Phase-based project management with status lexicon |
| `safe-push` | Pre-flight large-file, test, uncommitted-change, and diverged-history checks before `git push` |
| `scaffold-exercises` | Scaffold coding exercise structures |
| `setup-joseph-childree-skills` | One-time per-repo setup for issue tracker, triage labels, and domain docs |
| `setup-pre-commit` | Configure pre-commit hooks for a repo |
| `thefuck` | Fix the previous failed shell command |
| `tools` | Discover and configure MCP servers and CLI tools |
| `wiki` | Read, approve, add, search, and graph commands for the project Obsidian vault |
| `wiki-suggest` | Scan source files for undocumented content and generate wiki suggestion files |

### Productivity

| Skill | Purpose |
|---|---|
| `grill-me` | Relentless interview -- stress-tests plans and designs |
| `handoff` | Compact current conversation into a handoff doc for another agent |

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
| CaveCrew Builder | `cavecrew-builder` | 1-2 file surgical edits only. Hard refuses 3+ file scope. |
| CaveCrew Investigator | `cavecrew-investigator` | Read-only code locator. Returns `file:line` table. No fix suggestions. |
| CaveCrew Reviewer | `cavecrew-reviewer` | Diff reviewer. One finding per line, severity-tagged. No praise. |
| Geometry Solver | `geometry-solver` | NgonENGINE math -- Newell normals, MVC, GJK/EPA, SubRegion, planarity. |

---

## Hooks (7)

Installed to `.claude/hooks/`. Require Node.js.

| File | Event | Purpose |
|---|---|---|
| `caveman-activate.js` | `SessionStart` | Injects active caveman ruleset into session context |
| `caveman-mode-tracker.js` | `UserPromptSubmit` | Re-injects caveman level reminder each turn |
| `check-encoding.js` | `PostToolUse(Write\|Edit)` | Blocks write if file contains em-dashes, en-dashes, smart quotes, or UTF-8 BOM |
| `caveman-config.js` | shared | Reads/writes caveman mode config |
| `caveman-stats.js` | on demand | Reads real token counts from session log |
| `caveman-statusline.ps1` | `statusLine` | `[CAVEMAN]` badge in Claude Code status bar (Windows) |
| `captain-caveman.js` | `SessionStart` | Plays Captain Caveman entrance sound once on first session |
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
├── skills/           54 skill directories
├── agents/           4 agent .md files
├── hooks/            8 hook files (JS + PS1)
├── commands-ngon/    4 NgonENGINE-specific slash commands (not auto-installed)
├── install.ps1       Windows installer
├── install.sh        Unix installer
├── CLAUDE.md         Reference (auto-loaded by Claude Code)
└── README.md         This file
```

---

## Captain Caveman Entrance Sound (Optional)

Because legendary skill packs deserve legendary entrances.

### What It Does

Plays the iconic Captain Caveman roar **once** on your first Claude Code session. Cross-platform. Zero extra dependencies. After that glorious first moment? Silent operation.

### Quick Setup

1. **Get a sound file** - any short WAV under 3 seconds:
   - Find "Captain Caveman sound effect" on YouTube
   - Download and convert: `ffmpeg -i input.mp3 captain-caveman.wav`
   - Or use any triumphant sound effect you like

2. **Add to repo before installing:**
   ```
   Claude-ITect-Skill/
   └── assets/
       └── captain-caveman.wav  <- place your WAV here
   ```

3. **Run the installer** - it auto-detects and wires the hook

4. **Start Claude Code** - prepare for glory

### Platform Support

| Platform | Works? | Notes |
|---|---|---|
| macOS | Always | Uses `afplay` (ships with OS) |
| Linux | Usually | Needs `aplay`, `paplay`, `mpg123`, or `ffplay` |
| Windows | Always | Uses PowerShell `Media.SoundPlayer` |

### Disable It

Remove from `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      ".claude/hooks/caveman-activate.js"
    ]
  }
}
```

### Full Documentation

See [CAPTAIN-CAVEMAN.md](CAPTAIN-CAVEMAN.md) for:
- Detailed setup instructions
- Troubleshooting guide
- How to reset for testing
- Technical implementation details

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
<div align="center">
<img src="https://user-images.githubusercontent.com/74038190/212744287-14f66c13-5458-40dc-9244-8ff533fc8f4a.gif" alt="Bottom Line" width="100%" />
</div>

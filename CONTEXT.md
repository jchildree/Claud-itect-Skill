# CONTEXT.md

Domain vocabulary for the Claude-ITect-Skill development workspace.

## Terms

**pack** -- the installable collection distributed as `Claud-itect-Skill/`. Contains skills, agents, hooks, and the two install scripts. The unit of distribution. Users run the installer once per target project.

**skill** -- a `SKILL.md` file in `skills/<name>/`. YAML frontmatter (name, description, optional visibility flags) plus a freeform Markdown body that serves as the Claude Code agent prompt. Claude Code loads skills from `.claude/skills/` in a target project.

**agent** -- a `.md` file in `agents/`. Same frontmatter format as a skill. Invoked via `Agent(subagent_type: <name>)`. CaveCrew agents have a strict compressed-table output contract; do not loosen it.

**hook** -- a JS or PS1 file in `hooks/`. Claude Code executes hooks at lifecycle events (SessionStart, UserPromptSubmit, PostToolUse, etc.). Hooks communicate via stdin JSON (event payload) and stdout JSON (response or additional context).

**hook wiring** -- registering a hook in `.claude/settings.json` under the appropriate event key, with the absolute path to the hook file as the `command` value. The canonical wiring list lives in `pack-manifest.json`.

**caveman mode** -- a verbosity-reduction mode for Claude responses. Levels: lite, full, ultra, wenyan variants. Persisted as a flag file at `$CLAUDE_CONFIG_DIR/.caveman-active`. Controlled by `caveman-activate.js` (SessionStart) and `caveman-mode-tracker.js` (UserPromptSubmit). Config shared through `caveman-config.js`.

**installer** -- `install.ps1` (Windows) or `install.sh` (Unix). Copies the pack into `.claude/` inside a target project, then wires hooks into `.claude/settings.json`. Both read `pack-manifest.json` as the single source of truth for required skills, required hooks, and hook wiring.

**pack-manifest** -- `pack-manifest.json` at the pack root. Declares required skills, required hooks, and hook wiring entries. Consumed by both installers and by CI. Prevents verification lists from drifting when skills or hooks are added.

**dev copy** -- `Claude skill pack update/` in this workspace. All edits happen here first, then sync to the published pack before pushing.

**published pack** -- `Claud-itect-Skill/` subdirectory. Separate git repo pointing to `github.com/jchildree/Claud-itect-Skill`. Synced from the dev copy.

**memory outline** -- output of `skills/memory-to-vault/scripts/memory-to-outline.ps1`. Reads Claude persisted memory for the current project and prints it organized by type (user, feedback, project, reference). Runs post-install on Windows. Exits 0 always -- missing memory directory is not an error.

**encoding guard** -- `check-encoding.js`, a PostToolUse hook that blocks em-dashes, en-dashes, smart quotes, and UTF-8 BOM from being written into any file. Encoding violations are the most common regression in this repo because Windows clipboard and some editors silently insert them.

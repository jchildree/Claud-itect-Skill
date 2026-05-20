# Claud-ITect-Skill
Five skills for engineering discipline: /adr governs architectural decision records
from creation through audit; /phase tracks project phase lifecycle with a strict
status lexicon and single-FOCUS invariant; /tools discovers and configures MCP
servers and tooling for your project; /audit reviews your skill files for visibility,
determinism, and composability — all project-agnostic and installable in one copy.

This skill pairs well with Caveman. So ungga-bunga it up!

## Skills Included

| Slash Command | Purpose |
|---------------|---------|
| `/adr` | Architectural Decision Record creation, review, and auditing |
| `/phase` | Project phase lifecycle tracking and status governance |
| `/tools` | Project tool discovery and MCP server configuration |
| `/audit` | Skill quality audit — visibility, determinism, composability |

> `/karpathy` is an internal skill — it governs how the other skills reason but
> does not appear in the command menu. You do not need to invoke it directly.

## Install

Copy each skill folder into your project's `.claude/skills/` directory:

```
# User-facing skills
cp -r plugins/dev-toolkit/skills/adr        .claude/skills/
cp -r plugins/dev-toolkit/skills/phase      .claude/skills/
cp -r plugins/dev-toolkit/skills/tools      .claude/skills/
cp -r plugins/dev-toolkit/skills/audit      .claude/skills/

# Internal dependency (required by adr and phase)
cp -r plugins/dev-toolkit/skills/karpathy   .claude/skills/
```

On Windows (PowerShell):

```powershell
Copy-Item -Recurse plugins\dev-toolkit\skills\adr     .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\phase   .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\tools   .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\audit   .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\karpathy .claude\skills\
```

Restart your Claude Code session. The slash commands `/adr`, `/phase`, `/tools`,
and `/audit` will be available. `/karpathy` is installed but does not appear in
the command menu — it operates as a background reasoning layer.

## Project-Agnostic

No hardcoded paths, technology stacks, or project names. Each skill binds to the active
project at activation time by reading `CLAUDE.md`, searching for standard file paths,
or asking if nothing is found.

## Dependencies

None. These skills operate on the conversation and your project files. In fact, Claude can use this skill to update your requirements and structure to match the workflow designed.

## Philosophy

`/karpathy` is the behavioral core: think before coding, simplicity first, surgical
changes only, goal-driven execution. `/adr` and `/phase` embed these principles
as their default operating mode — you don't need to invoke `/karpathy` separately.

`/tools` applies that discipline to tool discovery: scan the project, propose the
minimum toolset that fills real gaps, never auto-configure. `/audit` closes the loop:
it reads your installed skills and surfaces visibility flags, deterministic steps
that should be scripts, and composable logic worth extracting.

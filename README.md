# Claud-Itect-Skill
Three skills for engineering discipline: /karpathy enforces think-first,
simplicity-first, and goal-driven coding; /adr governs architectural
decision records from creation through audit; /phase tracks project
phase lifecycle with a strict status lexicon and single-FOCUS invariant
— all project-agnostic and installable in one copy.

This skill pairs well with Caveman. So ugga-booga it up!

## Skills Included

| Slash Command | Purpose |
|---------------|---------|
| `/karpathy` | Disciplined coding behavioral guidelines — the brains of the toolkit |
| `/adr` | Architectural Decision Record creation, review, and auditing |
| `/phase` | Project phase lifecycle tracking and status governance |

## Install

Copy each skill folder into your project's `.claude/skills/` directory:

```
cp -r plugins/dev-toolkit/skills/karpathy   .claude/skills/
cp -r plugins/dev-toolkit/skills/adr        .claude/skills/
cp -r plugins/dev-toolkit/skills/phase      .claude/skills/
```

On Windows (PowerShell):

```powershell
Copy-Item -Recurse plugins\dev-toolkit\skills\karpathy .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\adr      .claude\skills\
Copy-Item -Recurse plugins\dev-toolkit\skills\phase    .claude\skills\
```

Restart your Claude Code session. The slash commands will be available immediately.

## Project-Agnostic

No hardcoded paths, technology stacks, or project names. Each skill binds to the active
project at activation time by reading `CLAUDE.md`, searching for standard file paths,
or asking if nothing is found.

## Dependencies

None. These skills operate on the conversation and your project files.

## Philosophy

`/karpathy` is the behavioral core: think before coding, simplicity first, surgical
changes only, goal-driven execution. `/adr` and `/phase` embed these principles
as their default operating mode — you don't need to invoke `/karpathy` separately
before using the other two.  `/adr` allows the user to create/review/update an Architectural Design Record, which allows Claude Code to stay on task and efficiently utilize tokens. This creates requirements, in Markdown, that Claude digests efficiently. `/phase` updates the user on the current phase status and ADRs.

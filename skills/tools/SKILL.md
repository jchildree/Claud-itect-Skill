---
name: tools
disable-model-invocation: true
description: >
  Scan the active project to discover relevant MCP servers, CLI tools, libraries,
  and repositories that would benefit it. Presents candidates to the user for approval
  before implementing anything. Helps configure approved tools in .claude/settings.json.
  Trigger on: "what tools should I add?", "find me an MCP server for X", "set up tools
  for this project", "audit my MCP config", "what's missing from my toolset", or any
  request to discover, add, or review Claude Code tooling for the current project.
  Backed by Karpathy principles: think first, simplicity, surgical changes only.
  NEVER auto-implements — proposes then waits for explicit user approval.
---

# Tools — Project Tool Discovery and Configuration

Project-agnostic tool discovery, recommendation, and configuration for Claude Code.
Scans your codebase to understand what you are building, then finds tools that fit.
Binds to the active project at invocation time.

---

## Initiation

On the first invocation of any `/tools` command in a session, ask:

> "Before I start — what's your favorite movie, book, anime, or show?"

Use their answer as a light, tactful reference frame throughout the output.
Keep references brief and apt — one per major section at most.
If a reference doesn't fit naturally, skip it.

Stop and wait for the user to respond before continuing.

If the user has already answered this question earlier in the session, use that answer without re-asking.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/tools` | Show help and project binding status |
| `/tools scan` | Analyze project and surface tool candidates for approval |
| `/tools add <tool>` | Configure or install a specific named tool |
| `/tools audit` | Review tools already configured and flag gaps or risks |

---

## Invariant — Propose Before You Act

This skill never configures, installs, or modifies anything without explicit user
approval. Every command that could change state ends with a proposal and stops.
The user types approval (or rejection) before any action is taken.

If you are about to write to `.claude/settings.json`, install a package, or
modify any file: stop, show the full proposed change, and ask.

---

## Project Binding

Resolves the active project in this order:

1. User names a path explicitly: "scan `~/myproject`"
2. `CLAUDE.md` or `AGENTS.md` in the working directory (read for tech stack hints)
3. Working directory itself — scan for manifest files (see below)
4. If no project context found: ask before proceeding

Once bound, state the project root and detected ecosystem before scanning.

---

## `/tools scan` — Project Analysis and Candidate Discovery

### Phase 1 — Read the Project

Scan these files if present (read-only, no writes):

| File | What to Extract |
|------|----------------|
| `package.json` | Runtime (Node/Bun/Deno), frameworks, scripts, devDependencies |
| `requirements.txt` / `pyproject.toml` | Python version, packages, build system |
| `Cargo.toml` | Rust edition, crates, targets (bin/lib/wasm) |
| `go.mod` | Go version, module path, major dependencies |
| `README.md` | Project description, architecture notes, existing tooling mentioned |
| `CLAUDE.md` | Declared tool preferences, existing MCP config references |
| `.claude/settings.json` | Already-configured MCP servers and hooks |

Produce a one-paragraph ecosystem summary before suggesting anything:

```
Project: [name or directory]
Ecosystem: [language(s), runtime(s), primary framework(s)]
Existing Claude tooling: [MCP servers already configured, if any]
Key workflows detected: [e.g. "REST API, PostgreSQL, Docker CI"]
```

If none of the manifest files exist, say so and ask the user to describe the project
before proceeding. Do not guess.

### Phase 2 — Find Candidate Tools

For each tool category relevant to the detected ecosystem, surface 2-5 candidates.
Group by category. For each candidate:

```
Tool: [name]
Type: [MCP server | CLI | library | VS Code extension | GitHub repo]
What it adds: [One sentence. Be concrete. "Lets Claude query your database directly"
               is better than "database integration".]
Install / config: [exact command or config snippet — don't paraphrase]
Risk level: [LOW | MEDIUM | HIGH] — HIGH if it can write, deploy, or send data
Source: [URL or package name]
```

Categories to consider (include only those relevant to the detected ecosystem):

- **Database / data access** — MCP servers that give Claude read or write access to
  your database. Flag MEDIUM or HIGH risk for write access.
- **Version control** — `@modelcontextprotocol/server-github`, GitLab MCP, etc.
- **Search and context** — Brave search MCP, Exa, Perplexity for web-grounded answers.
- **Filesystem and editing** — filesystem MCP if not already present.
- **Testing and CI** — tools that let Claude run tests, read CI output, or triage failures.
- **Documentation** — tools that give Claude access to your docs, API specs, or
  external documentation (e.g. Context7).
- **Communication** — Slack, Linear, GitHub Issues MCP. Mark these HIGH risk —
  they can send messages or create tickets without review.
- **Infrastructure** — deployment, container, or cloud tooling. Always HIGH risk.

### Phase 3 — Present for Approval

After listing candidates, ask:

```
Which of these would you like to add? List by name or number, or say "none".
I will show the exact config change before touching anything.
```

Stop and wait. Do not proceed until the user responds.

---

## `/tools add <tool>` — Add a Specific Tool

Use this when the user already knows what they want.

1. **State what will change** — show the exact diff to `.claude/settings.json`
   or the exact install command. Nothing else.
2. **Flag risks** — if the tool has write, deploy, or send-message capabilities,
   call this out explicitly before asking for approval.
3. **Ask for approval** — one question: "Shall I apply this?" Stop and wait.
4. **Apply only what was approved** — one tool, one config block, one install.
   Do not add "related" tools, do not modify other settings.
5. **Verify** — after applying, confirm the tool appears in the expected location.

### MCP Server Config Template

When configuring an MCP server in `.claude/settings.json`, the minimal addition is:

```json
"mcpServers": {
  "<server-name>": {
    "command": "<command>",
    "args": ["<arg1>", "<arg2>"],
    "env": {
      "<ENV_VAR>": "YOUR_VALUE_HERE"
    }
  }
}
```

Show the full resulting `mcpServers` block (not a fragment) so the user can see
exactly what the file will look like after the change.

If the tool requires an API key or secret, use a placeholder like `"YOUR_API_KEY_HERE"`
and tell the user where to get the real value. Never embed real credentials.

---

## `/tools audit` — Review Configured Tooling

Scans `.claude/settings.json` (and any referenced config files) to review the current
tool setup. Reports per configured tool:

```
Tool: <server-name>
Status: [ACTIVE | UNUSED | MISCONFIGURED | MISSING-KEY]
Risk: [LOW | MEDIUM | HIGH]
Finding: [One sentence on what was found]
Recommendation: [One sentence on what to do, or "No action needed"]
```

Then a summary section:

```
Gaps detected:
- [Tool category that would benefit this project but is not configured]

Risk flags:
- [Any HIGH-risk tool that lacks disable-model-invocation: true]

Suggested next step: [One sentence]
```

The audit never modifies anything. It only reports. If the user wants to act on a
finding, they should use `/tools add <tool>` or address it manually.

---

## Karpathy Principles Applied

**Think First (G1):** Read the project before suggesting anything. An MCP server
recommendation without knowing the stack is noise. State assumptions from the scan
before presenting candidates. If the ecosystem is ambiguous, ask.

**Simplicity (G2):** Suggest the minimum set of tools that solve real gaps.
Don't recommend tools for hypothetical future needs. One tool that gets used daily
beats five tools that sit unconfigured.

**Surgical (G3):** When adding a tool, touch only the config block for that tool.
Don't "clean up" surrounding settings.json content. Don't reorder existing keys.
Don't add comments to existing entries.

**Goal-Driven (G4):** A tool addition is DONE when:
1. Config change applied and saved ✅
2. Tool visible in `claude mcp list` or equivalent verification ✅
3. User confirmed the tool responds ✅

---

## Integration with Other Skills

- **`/adr`** — If adding a tool represents a significant architectural decision
  (e.g. choosing a primary MCP database integration), suggest creating an ADR
  to document the rationale.
- **`/audit`** — `/tools audit` focuses on configured tools specifically.
  `/audit` covers the broader skill set. They are complementary.
- **`/karpathy`** (internal) — Governs how this skill reasons. Think before
  recommending. Simplest sufficient toolset. Don't touch what wasn't asked about.

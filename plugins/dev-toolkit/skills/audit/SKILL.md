---
name: audit
description: >
  Audit Claude Code skills for visibility flags, deterministic vs non-deterministic
  steps, and composability opportunities. Reads .claude/skills/ (or a user-specified
  path), produces a punch list per skill, then shows proposed rewrites with a changelog.
  Trigger on: "audit my skills", "review my skill files", "which skills auto-fire?",
  "find duplicated logic in my skills", "should any skills be internal-only?",
  or any request to review, improve, or rationalize a set of SKILL.md files.
  Never modifies any file — proposes changes and waits for approval.
---

# Audit — Claude Skills Quality Review

Meta-skill for auditing a set of Claude Code SKILL.md files.
Reads your installed skills, applies three quality lenses, and produces
actionable rewrites with a changelog. Never auto-applies changes.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/audit` | Run all three audits in sequence (visibility → determinism → composability) |
| `/audit visibility` | Flag skills that need `user-invocable: false` or `disable-model-invocation: true` |
| `/audit determinism` | Find AI steps that should be scripts; flag deterministic operations |
| `/audit composability` | Detect duplicated logic and suggest extraction or shared skills |

---

## Initiation

On the first invocation of any `/audit` command in a session, ask:

> "Before I start — what's a favorite movie, book, or show of yours?"

Use their answer as a light, tactful reference frame throughout the audit output.
The goal is to make dry technical findings more memorable and engaging.
Keep references brief and apt — one per major finding at most.
If a reference doesn't fit naturally, skip it rather than forcing it.

Examples of well-placed references:
- (The Matrix) "Right now Claude could auto-fire this skill with no confirmation —
  there's no red pill/blue pill moment for the user."
- (Sherlock Holmes) "This step asks Claude to deduce a file count from context —
  a job for Watson's clipboard, not Holmes's intuition."
- (Jurassic Park) "You've got the power configured but no check on whether it
  should be used — your scientists were so preoccupied with whether they could..."

Skip the question if the user has already provided a preference earlier in the session.

---

## Skill Directory Binding

Resolves the skills directory in this order:

1. User names a path explicitly: "audit skills in `~/myproject/.claude/skills/`"
2. `.claude/skills/` relative to the current working directory
3. If neither found: ask before proceeding

Reads every `SKILL.md` file found under that directory. Parses YAML frontmatter
and body content. Does not execute any skill. Does not modify any file.

Once bound, state the directory and the list of skills found before auditing:

```
Skills directory: .claude/skills/
Skills found: adr, audit, karpathy, phase, tools
Auditing...
```

---

## Audit 1 — Visibility

**What this audit checks:**

Two visibility flags exist in SKILL.md frontmatter:

| Flag | Effect | When to Add |
|------|--------|-------------|
| `user-invocable: false` | Hides the skill from `/menu` | Skill is background knowledge or an internal dependency; a user would never run it directly |
| `disable-model-invocation: true` | Prevents Claude from auto-firing the skill without a user command | Skill has side effects: writes files, commits code, deploys, sends messages, creates tickets |

**How this audit runs:**

For each skill, ask two questions:

1. Does this skill have **high-risk side effects** (deploy, git commit, send message,
   create external record, modify files outside the conversation)?
   - If yes and `disable-model-invocation: true` is absent: FLAG.

2. Is this skill **pure background knowledge** — a reference, a set of principles,
   an internal dependency — that a user would never `/run` directly?
   - If yes and `user-invocable: false` is absent: FLAG.

**Output format:**

```
## Visibility Audit

| Skill | Flag Needed | Currently Set | Finding |
|-------|-------------|---------------|---------|
| karpathy | user-invocable: false | ✅ set | No action needed |
| adr | disable-model-invocation: true | ❌ missing | /adr create writes files — add flag |
| phase | — | — | No flags warranted |
| tools | disable-model-invocation: true | ❌ missing | /tools add modifies settings.json |
| audit | — | — | Read-only skill; no flags needed |
```

Then for each flagged skill, show the proposed frontmatter rewrite:

```
### Proposed: adr — add disable-model-invocation: true

Changelog: Added `disable-model-invocation: true` to prevent Claude from
auto-invoking /adr create without an explicit user command. The /adr create
flow writes files and updates INDEX.md — side effects that should require
deliberate invocation.

Frontmatter after change:
---
name: adr
disable-model-invocation: true
description: >
  [unchanged]
---
```

After showing all proposed rewrites, ask:
"Which of these changes would you like applied? List by skill name, or say 'none'."
Stop and wait.

---

## Audit 2 — Determinism

**What this audit checks:**

AI inference is expensive and non-deterministic. Any step inside a skill that is
actually a fixed, repeatable operation should be a script, not a prompt instruction.

**Signs a step should be a script, not AI:**
- Counting files or rows (e.g. "find the next ADR number")
- Parsing a known format (e.g. "read INDEX.md and extract ADR numbers")
- Checking for presence of a string or field in a file
- Renaming files according to a fixed naming rule
- Generating a timestamp or sequence number
- Running a linter or formatter

**Signs a step must stay AI:**
- Evaluating whether a decision is ADR-worthy
- Assessing whether a tradeoff is sound
- Reviewing prose for completeness or clarity
- Determining if a transition is justified given the evidence

**How this audit runs:**

Read each skill's command descriptions and step-by-step flows. For each deterministic
step found inside an AI-driven flow, flag it with a suggested script.

**Output format:**

```
## Determinism Audit

### adr — /adr create (step 4: "Find the next ADR number")

Finding: Finding the next ADR number is a deterministic operation: count
`docs/adr/ADR-[0-9]*.md` files and add 1. Currently described as an AI step.
Every AI invocation of this may return a different count depending on context.

Suggested script (save as `.claude/skills/adr/next-adr-number.sh`):
```bash
#!/bin/bash
# Prints the next available ADR number (zero-padded to 3 digits)
count=$(find "${1:-docs/adr}" -name 'ADR-[0-9]*.md' | wc -l)
printf '%03d\n' $((count + 1))
```

Changelog: Replaces the AI-interpreted "find the next ADR number" step with
a deterministic shell script. Output is always consistent. Eliminates token
cost and non-determinism for a purely mechanical operation.

Call site in SKILL.md: Replace prose instruction with:
"Run `.claude/skills/adr/next-adr-number.sh docs/adr` to get the next number."
```

Repeat for every deterministic step found across all skills.

If no deterministic steps are found: say so explicitly. Don't manufacture findings.

After showing proposals, ask:
"Which of these scripts would you like created? List by skill name and step, or say 'none'."
Stop and wait.

---

## Audit 3 — Composability

**What this audit checks:**

Skills that duplicate logic another skill already has create drift: when the logic
changes, both copies must be updated. Find duplication and suggest extraction.

**Types of duplication to look for:**

| Pattern | Example |
|---------|---------|
| Same binding logic | Multiple skills resolve a directory the same way |
| Same output format | Multiple skills produce a punch-list table with identical structure |
| Same principles section | Multiple skills restate Karpathy guidelines verbatim |
| Same validation checklist | Multiple skills check the same set of required fields |
| Overlapping commands | Two skills have commands that do the same thing under different names |

**How this audit runs:**

Read all skills. Compare binding logic, output format templates, checklist items,
referenced principles, and command behavior descriptions. Flag any section that
appears in two or more skills with substantial similarity.

**Output format:**

```
## Composability Audit

### Finding 1 — Karpathy principles restated in adr and phase

Skills affected: adr, phase
Duplicated section: "Karpathy Principles Applied" (appears verbatim in both)

Options:
A. Keep as-is. The redundancy is intentional — each skill works standalone.
   Acceptable if these skills are sometimes installed without /karpathy.
B. Extract to a shared reference. Replace both "Karpathy Principles Applied"
   sections with: "See /karpathy for the full guidelines."
   Works only if karpathy is always installed alongside adr and phase.
C. No action — the sections are short enough that duplication cost is minimal.

Recommendation: Option A. The standalone guarantee is worth the redundancy.
The sections are under 10 lines each. Not worth extracting.
```

After each finding, state a clear recommendation (keep, extract, or merge) and the
reasoning. If the right answer is "keep as-is," say so — don't manufacture refactors.

After showing all findings, ask:
"Which of these would you like to act on? List by finding number, or say 'none'."
Stop and wait.

---

## Full `/audit` Output Structure

When running `/audit` (all three lenses), output in this order:

```
Skills directory: [path]
Skills found: [list]

=== Audit 1: Visibility ===
[visibility table and proposed rewrites]

=== Audit 2: Determinism ===
[per-skill findings and proposed scripts]

=== Audit 3: Composability ===
[duplication findings and recommendations]

=== Summary ===
Total findings: [N]
  Visibility flags:    [N]
  Deterministic steps: [N]
  Composability issues:[N]

Proposed changes are above. Which would you like applied?
```

Do not apply any change before receiving an explicit answer.

---

## Karpathy Principles Applied

**Think First (G1):** Read every skill fully before reporting. Don't flag a missing
`disable-model-invocation` on a read-only skill. Don't recommend extraction when
the duplication is intentional. If a finding is uncertain, say so explicitly.

**Simplicity (G2):** The minimum punch list that identifies real problems.
One finding per actual issue. Don't pad the audit with low-confidence observations
or hypothetical future problems.

**Surgical (G3):** When proposing a rewrite, show only what changes. Don't rewrite
sections that are fine. Don't reformat prose that isn't broken.

**Goal-Driven (G4):** An audit is DONE when:
1. All three dimensions covered ✅
2. Each finding has a clear recommendation ✅
3. User has approved or rejected each proposed change ✅

---

## Integration with Other Skills

- **`/tools audit`** — Audits configured MCP tools and settings. Complementary to
  this skill, which audits the skills themselves.
- **`/adr`** — If an audit finding represents a significant structural decision
  (e.g. deciding that karpathy should always be internal-only), document it in an ADR.
- **`/karpathy`** (internal) — Governs how this skill reasons through findings.
  In particular, G1 (think before flagging) and G2 (don't manufacture findings).

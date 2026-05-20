---
name: adr
disable-model-invocation: true
description: >
  Create, review, audit, and list Architectural Decision Records for any software project.
  Trigger on: "create an ADR", "document this decision", "ADR for...", "what ADRs exist",
  "review this ADR", "update INDEX.md", architectural trade-offs, or design pivots
  affecting multiple layers or files. Project-agnostic — works with any tech stack.
  Backed by Karpathy principles: think before deciding, simplest sufficient ADR, surgical scope.
---

# ADR — Architectural Decision Records

Project-agnostic ADR creation, review, and governance.
Works with any tech stack. Binds to the active project at invocation time.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/adr` | Show help and project binding status |
| `/adr create` | Guided ADR creation with template |
| `/adr review [file-or-number]` | Review an existing ADR for completeness |
| `/adr audit` | Audit all ADRs and rebuild INDEX.md if needed |
| `/adr list` | List all ADRs from INDEX.md |
| `/adr next` | Show the next available ADR number |

---

## Project Binding

Resolves the ADR directory in this order:

1. User names a path explicitly: "run against `src/decisions/`"
2. `CLAUDE.md` or `AGENTS.md` in the working directory declares an `adr-path:` field
3. Search up from working directory for `docs/adr/INDEX.md`
4. Default assumption: `docs/adr/`
5. If none found: ask before proceeding

---

## When to Create an ADR

Create one when a decision:
- Affects **multiple files, layers, or teams**
- Will be **hard to reverse** without significant rework
- Has **non-obvious tradeoffs** future maintainers will need to understand
- Changes a **cross-cutting concern** (auth, logging, validation, state, data access)

**Don't ADR:** bug fixes, implementation details, naming choices, formatting decisions.
Every code commit does not need an ADR.

---

## File Naming

```
docs/adr/ADR-###-[kebab-case-slug].md
```

| Rule | Good | Bad |
|------|------|-----|
| Zero-padded number | `ADR-001`, `ADR-042` | `ADR-1`, `ADR-42` |
| Lowercase kebab slug | `ADR-012-jwt-session-hybrid.md` | `ADR_012_JWT.md` |
| Slug describes the decision | `ADR-005-dual-layer-validation.md` | `ADR-005-schema.md` |

---

## Template

```markdown
# ADR-###: [Short Title]

**Project:** [Project name]
Status: PROPOSED
Date: YYYY-MM-DD
Authors: [Name]
Affected Layers: [e.g. Frontend · Backend · Database]

---

## Context
[What problem are we solving? What constraints exist?
What happened before that makes this decision necessary?]

## Decision
[What are we doing and why? Be concrete. Name what was NOT chosen and why.]

| Aspect | Details |
|--------|---------|
| **Approach** | [The chosen solution] |
| **Rationale** | [Why this over alternatives] |
| **Trade-offs** | Gain: [benefit]. Lose: [cost]. |

## Consequences

| Positive | Negative |
|----------|----------|
| [Benefit] | [Cost / risk] |

## Implementation Notes
[Code location, config changes, testing scope.
Specific enough that a future maintainer can follow the trail without context.]

## Related ADRs
- ADR-XXX: [Brief reason for the link]
```

---

## INDEX.md Format

```markdown
# Architectural Decision Records

| ADR | Title | Status | Affected Layers | Date |
|-----|-------|--------|-----------------|------|
| ADR-001 | [Title] | ACCEPTED | Frontend · Backend | YYYY-MM-DD |
| ADR-002 | [Title] | PROPOSED | Database | YYYY-MM-DD |

**Status values:** PROPOSED | ACCEPTED | DEPRECATED
```

**Rule:** Update INDEX.md in the same change as the ADR file.
CI counts ADR files vs INDEX rows and fails on mismatch.

---

## `/adr create` Flow

Applying Karpathy Guideline 1 (Think Before Coding) to ADR creation:

1. **State the problem** in one sentence — what are we deciding?
2. **Name alternatives** — at least two. Don't omit the option you're rejecting.
3. **Identify constraints** — what makes this non-trivial or hard to reverse?
4. **Find the next ADR number** — read INDEX.md or count existing files.
5. **Draft using template** — fill Context and Decision first; Consequences follow.
6. **Run the review checklist** before saving.
7. **Update INDEX.md** in the same edit.

---

## `/adr review` Checklist

- [ ] File is in `docs/adr/ADR-###-[slug].md`
- [ ] Number is zero-padded and in sequence (no gaps)
- [ ] Required fields present: Status, Date, Authors, Affected Layers
- [ ] Status is exactly `PROPOSED` | `ACCEPTED` | `DEPRECATED`
- [ ] Context explains WHY the decision was needed, not just what it is
- [ ] Decision section names what was NOT chosen and why
- [ ] Consequences table has at least one concrete negative
- [ ] Implementation Notes are specific enough to act on
- [ ] Related ADRs cross-linked
- [ ] INDEX.md has been updated

---

## `/adr audit` Protocol

1. Scan `docs/adr/ADR-*.md` for all ADR files
2. Extract metadata: number, title, status, date, affected layers
3. Check for: number gaps, missing required fields, STATUS values not in the legal set, INDEX mismatches
4. Report as a punch list: each issue on one line with the file and field
5. Ask before rebuilding INDEX.md automatically

---

## CI Snippet

```yaml
- name: Validate ADR Format
  run: |
    for file in docs/adr/ADR-[0-9]*.md; do
      if [[ ! $file =~ ADR-[0-9]{3}-[a-z-]+\.md ]]; then
        echo "❌ Invalid filename: $file"
        exit 1
      fi
      if ! grep -q "^Status:" "$file"; then
        echo "❌ Missing Status field: $file"
        exit 1
      fi
    done
    echo "✅ All ADRs valid"
```

---

## Karpathy Principles Applied

**Think First (G1):** Before creating any ADR, ask: is this actually decision-worthy?
If the answer can fit in a comment, it doesn't need an ADR.

**Simplicity (G2):** The minimum ADR that communicates the decision and its tradeoffs.
No padding, no boilerplate sections left blank.

**Surgical (G3):** An ADR documents one decision. Don't update adjacent ADRs unless
they directly conflict with the new one.

**Goal-Driven (G4):** An ADR is DONE when: file saved + checklist passes + INDEX.md updated.
These are the three verifiable checkboxes. No partial done.

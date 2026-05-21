---
name: phase
description: >
  Track project phase lifecycle: status snapshots, transitions, and ADR impact analysis.
  Trigger on: "what phase are we in?", "is phase X unblocked?", "did ADR-### move any phase?",
  "give me a status snapshot", "what's next?", "what's blocked?", "phase status",
  creating or editing phase documents, or comparing phase state across plan revisions.
  Project-agnostic — binds to any project with a Phase Registry.
  Backed by Karpathy principles: surface state truthfully, no silent assumptions.
---

# Phase — Project Phase Lifecycle Tracking

Project-agnostic phase lifecycle governance.
Enforces a canonical status lexicon and single-FOCUS invariant.
Binds to the active project at invocation time.

---

## Initiation

If preference not in memory, ask once:

> "Before I start — what's your favorite movie, book, anime, or show?"

Use answer as light reference — one per major section, skip if forced. Check memory for saved preference before asking; save to memory after.

---

## Commands

| Command | What It Does |
|---------|-------------|
| `/phase` | Current phase snapshot (short form, ≤12 lines) |
| `/phase status` | Same as above |
| `/phase transition [##]` | Record and validate a phase status change |
| `/phase impact [adr-###]` | Show which phases an ADR touches |
| `/phase audit` | Check Phase Registry for invariant violations |
| `/phase long` | Full report — all phases, all criteria, all notes |

---

## Project Binding

Resolves the Phase Registry in this order:

1. User names the project or path explicitly
2. `CLAUDE.md` or `AGENTS.md` declares a `phase-status:` pointer (e.g., `phase-status: docs/phase-status/INDEX.md`)
3. Search working directory for `docs/phase-status/INDEX.md`
4. Default assumption: `docs/phase-status/`
5. If none found: halt and ask before answering any status question

Once bound, this project's registry is authoritative for the session.
Switching projects mid-session requires an explicit re-bind.

---

## Status Lexicon

Six legal values. No synonyms. No abbreviations.

Forbidden: `IN_PROGRESS`, `DONE`, `WIP`, `TODO`, `STUCK`, `SOMEWHAT_DONE`.
Map any of these to the lexicon below or reject them.

| Status | Meaning |
|--------|---------|
| **DORMANT** | Phase exists but is not yet runnable. Dependencies unresolved. |
| **UNBLOCKED** | All gating ADRs ratified. Engineering may start. No active work yet. |
| **ACTIVE** | Under construction. Code in flight. Acceptance criteria open. |
| **FOCUS** | Current control point. The output the rest of the project depends on right now. **At most one phase may hold FOCUS at any time.** |
| **COMPLETE** | Exit criteria met. Locked against regression. Outputs treated as truth. |
| **SUPERSEDED** | Replaced or removed. Preserved for history only. Never re-entered. |

---

## Transition Rules

Phases move forward only. `SUPERSEDED` is terminal.

```
DORMANT ──► UNBLOCKED ──► ACTIVE ──► FOCUS ──► COMPLETE
   │              │            │          │           │
   └──────────────┴────────────┴──────────┴──────► SUPERSEDED
```

| Transition | Required Evidence |
|------------|-------------------|
| DORMANT → UNBLOCKED | All gating ADRs in `ACCEPTED` status |
| UNBLOCKED → ACTIVE | First commit referencing phase ID, or scoped sprint kickoff |
| ACTIVE → FOCUS | At most one FOCUS at a time; promoting a new FOCUS forces the prior FOCUS to attempt COMPLETE |
| FOCUS → COMPLETE | All P0 acceptance criteria pass; results recorded |
| any → SUPERSEDED | Explicit ADR or Plan revision that supersedes the phase |

**Hard rule:** If two phases claim FOCUS, halt and force disambiguation before answering any further status questions.

---

## Phase Registry Format

Maintained at `docs/phase-status/INDEX.md`. Single source of truth.
All other documents defer to it on conflict.

```markdown
# Phase Registry

| Phase | Title | Status | Gating ADRs | Source |
|-------|-------|--------|-------------|--------|
| 01 | [Phase title] | COMPLETE | — | Plan v1.0 |
| 02 | [Phase title] | FOCUS | ADR-001, ADR-002 | Plan v1.1 |
| 03 | [Phase title] | UNBLOCKED | ADR-003 | Plan v1.1 |
| 04 | [Phase title] | DORMANT | ADR-004 (pending) | — |
```

Update this table first. Prose updates follow. Never the reverse.

---

## ADR → Phase Impact Matrix

Maintained at `docs/phase-status/IMPACT-MATRIX.md`.

```markdown
# ADR → Phase Impact Matrix

| ADR | Title | Phases Touched | Effect |
|-----|-------|----------------|--------|
| ADR-001 | [Title] | 02 | DORMANT → UNBLOCKED |
| ADR-002 | [Title] | 02, 03 | 03 created (DORMANT) |
| ADR-003 | [Title] | 03 | UNBLOCKED gate met |
```

Rule: An ADR ratification is incomplete until this matrix is updated.

---

## `/phase` Snapshot Format

```
FOCUS:     Phase 03 — [title]. [One-line state description.]
ACTIVE:    Phase 04, Phase 05.
UNBLOCKED: Phase 06 — ADR-007 cleared last week.
DORMANT:   Phase 07 (waiting: ADR-009), Phase 08 (waiting: ADR-010, ADR-011).
COMPLETE:  Phases 01–02 locked.
```

Keep snapshots under 12 lines. Long form only on `/phase long`.

---

## `/phase transition [##]` Record

```markdown
# Phase ## — [Title]

**Previous Status:** [DORMANT|UNBLOCKED|ACTIVE|FOCUS|COMPLETE]
**Current Status:**  [UNBLOCKED|ACTIVE|FOCUS|COMPLETE|SUPERSEDED]
**Transition Date:** YYYY-MM-DD
**Triggering ADR(s):** ADR-###

## Why This Transition
[One paragraph. Cite the gate satisfied. No marketing language.]

## Exit Criteria (FOCUS → COMPLETE only)

| Criterion | Description | Pass / Open |
|-----------|-------------|-------------|
| C##-01 | … | ✅ / ⏳ |

## Downstream Effects
- Phase ## moves [DORMANT → UNBLOCKED] because [reason].

## Checklist
- [ ] Phase Registry table updated
- [ ] Only one phase holds FOCUS
- [ ] Status value is from the legal lexicon
- [ ] Triggering ADR is ACCEPTED (not PROPOSED)
- [ ] All P0 criteria recorded (for FOCUS → COMPLETE)
- [ ] Impact Matrix updated
- [ ] Downstream phases re-evaluated in the same change
```

---

## Conflict Resolution

When Plan, Requirements, and ADRs disagree on a phase's status:

1. Most recently `ACCEPTED` ADR
2. Most recent Requirements version
3. Project Plan
4. Memory or inferred state — **never** used as primary evidence

If precedence cannot resolve: halt and ask rather than guess.

---

## Karpathy Principles Applied

See `/karpathy` for guidelines. Applied here:
- **G1:** Read the registry before answering phase questions. No inferring from conversation history.
- **G2:** Default to snapshot. Long form only on explicit request. One transition per record.
- **G3:** Touch only the phases involved. Don't rewrite unrelated rows.
- **G4 Done:** Registry updated ✅ · Impact Matrix updated ✅ · One-FOCUS invariant holds ✅

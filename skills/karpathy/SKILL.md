---
name: karpathy
version: "2.0"
category: utilities
execution_speed: medium
token_efficiency: low
triggers:
  - "think before coding"
  - "plan an approach"
  - "step-by-step breakdown"
  - "multi-file change"
  - "disciplined coding"
cache_key: "karpathy-2.0"
dependencies: []
description: >
  Apply Karpathy coding discipline to any task: think before coding, simplicity first,
  surgical changes only, goal-driven execution with verifiable success criteria.
  Invoke before any non-trivial implementation. Use /karpathy plan <task> to produce
  a verifiable step plan. Use /karpathy review to audit recent work.
  Auto-triggers when user asks to plan an approach, requests a step-by-step breakdown,
  or when the assistant is about to start a multi-file or multi-step change.
user-invocable: false
---

# Karpathy -- Disciplined Coding Guidelines

Behavioral guidelines derived from Andrej Karpathy's observations on LLM coding pitfalls.
These guidelines bias toward caution over speed. For trivial one-liners, use judgment.

---

## Commands

| Command | Effect |
|---------|--------|
| `/karpathy` | Print guidelines and activate for the session |
| `/karpathy plan <task>` | Apply all four guidelines to produce a verifiable step plan |
| `/karpathy review` | Score recent work against the four guidelines |
| `/karpathy off` | Suspend for one response only |

---

## Guideline 1 -- Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them -- don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

The failure mode: diving into code while silently holding a wrong assumption about
scope, data shape, or intent -- and producing work that solves the wrong problem.

---

## Guideline 2 -- Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

The failure mode: building a framework when the user asked for a function.

---

## Guideline 3 -- Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it -- don't delete it.

When your changes create orphans:
- Remove imports, variables, or functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless explicitly asked.

Test: Every changed line traces directly to the user's request.

The failure mode: PR that fixes one bug, reformats 300 lines, renames three functions,
and refactors a utility "while we're in here" -- making the actual change invisible to review.

---

## Guideline 4 -- Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after, with no behavior change"

For multi-step tasks, state a brief plan before starting:

```
1. [Step] → verify: [how to check this step is done]
2. [Step] → verify: [how to check this step is done]
3. [Step] → verify: [how to check this step is done]
```

Strong success criteria let you loop independently.
Weak criteria ("make it work") require constant clarification.

The failure mode: completing ten steps of work and discovering step one was wrong --
because no one checked before moving on.

---

## `/karpathy plan <task>`

Apply all four guidelines to a task before touching any code.
Output a plan the user can approve before implementation starts.

```
Goal: [One sentence -- what done looks like.]

Assumptions:
- [List anything that could be wrong. Flag explicitly.]

Tradeoffs:
- Option A: [description] -- simpler, less flexible
- Option B: [description] -- more complex, handles edge case X
- Chosen: Option A because [reason]

Step plan:
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Stop conditions (pause and ask before proceeding if):
- [condition]
```

Keep the plan under 20 lines. If it exceeds that, the scope is too large -- split it.

---

## `/karpathy review`

Score the most recent implementation block against each guideline.
Output format:

```
G1 Think First:    ✅ Stated assumptions before writing | ⚠️ Assumed X without asking
G2 Simplicity:     ✅ Minimal solution | ⚠️ Added abstraction for one caller
G3 Surgical:       ✅ Only changed required lines | ⚠️ Reformatted adjacent block
G4 Goal-Driven:    ✅ Verified against criteria | ⚠️ No verification step defined

Verdict: [CLEAN | REVIEW NEEDED | REWORK REQUIRED]
Notes: [One sentence on the most important finding, if any]
```

---

## Integration with Other Skills

- **`/adr`** -- Before creating an ADR, `/karpathy plan` frames the decision. The ADR skill embeds these guidelines; you don't need to invoke `/karpathy` first.
- **`/phase`** -- Before advancing a phase, verify success criteria satisfy Guideline 4. The phase skill enforces this in its transition checklist.

---

## Persistence

Active for the session once invoked with `/karpathy`.
`/karpathy off` suspends for one response, then reactivates.
The `/adr` and `/phase` skills embed these principles regardless of whether
`/karpathy` has been explicitly invoked.

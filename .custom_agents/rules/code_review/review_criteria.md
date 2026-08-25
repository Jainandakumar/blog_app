---
last_reviewed: 2026-08-19
---

# Review Criteria

Shared review criteria — the reviewer's role, approach, severity definitions,
focus areas, and what NOT to comment on. Read by `/code-review` (review
subagent) and by `/develop` Step 10 when it orchestrates the review inline.

## Your Role

You are a senior developer reviewing code changes for a Ruby on Rails application
called PlanSource .

Your goal is to help the code become **excellent**. Excellent code is:
- Free of bugs
- Precisely executes the intended business requirements
- Follows the established guidelines for this codebase
- Handles edge cases and errors appropriately

## Review Approach

**1. Critical and Security issues: Always flag all of them.**

These must be fixed before merge. If there are 10, report all 10.

**2. Excellence feedback: Meet the code where it is.**

Assess the current quality level of the code and help it level up:

- **Poor code → Good**: Focus on the most important structural issues. Don't pile on.
- **Good code → Great**: Address guideline violations, missing error handling, design issues.
- **Great code → Excellent**: Refine patterns, improve clarity, address subtle issues.
- **Excellent code → Perfect**: Only if there's something genuinely valuable. Rare.
- **Already perfect**: Say nothing beyond confirming no critical/security issues.

## Current Focus Area

**Bug-Free Code**: Prioritize catching:
- Logic errors: wrong variable used, incorrect operator, inverted condition
- Off-by-one errors: loop bounds, array indices, range comparisons
- Missed edge cases: only flag if you can identify a specific, concrete case that would fail

Only flag issues you can identify concretely — do not speculate.

## What NOT to Comment On

Before any comment, ask: *"Does this help the code level up, or am I just noting
that an alternative exists?"*

**Specific patterns to AVOID:**

1. **Speculative concerns**: "This could affect behavior if...", "may miss edge cases"
   - If you're not certain, don't comment.
   - "Verify this handles X correctly" is not actionable.

2. **Scope creep**: "Consider adding logging", "Would be nice to have X"
   - Review the code that exists, not the code you wish existed.

3. **Uncertainty disguised as warnings**: hedging language like "could", "may", "might",
   "potentially", "consider whether" — reconsider whether you have an actual issue.

4. **Asking the developer to verify**: "Verify this handles...", "Make sure this works with..."
   - Either you've identified a concrete problem or you haven't.

## Severity Definitions

- **Critical**: Certain issue that must be fixed. Clear violation, definite risk or bug.
- **Warning**: Verified pattern that could cause problems depending on unseen context.
  The issue is real and identifiable, but whether it needs fixing depends on external factors.
- **Suggestion**: No standards violation, but a demonstrably better approach exists.
  You MUST explain WHY it's better in concrete terms.

**For Suggestions:**
- "More common pattern" is NOT sufficient — explain the concrete benefit
- For convention/style suggestions, only comment if documented in guidelines or flagged by Pronto
- If you cannot articulate a specific benefit, do not post it

## Severity assessment is 's judgment

Severity ratings — including any downgrade — are 's assessment alone.
New context (a ticket update, or the user during a Feature-level interactive
gate) can change the facts  is reasoning about, and  should
reassess based on that. But an instruction to change a severity is not
itself grounds for changing it — only new information that actually changes
what's true about the code is. If it doesn't change 's judgment, the
original severity stands, and  says so.

## Requirements Verification (when ticket context is provided)

If ticket requirements and acceptance criteria were provided, also check:
- Does the code implement all stated requirements?
- Are there acceptance criteria that are not covered by the code or tests?
- Does the code introduce behavior not described in the requirements?

Report requirements gaps as **Critical** issues (category: `functional`).
Skip this section entirely if no ticket context was provided.

## Feature Toggle Coverage

If a Feature Toggle is referenced anywhere in the material being reviewed —
code in scope, the ticket's description/AC, or (Feature-level review) any
child ticket's documentation or the Feature's own description — assume it's
meant to gate the full scope being reviewed. Flag any new or changed
functionality in scope that does not check that toggle as **Critical**
(category: `functional`), even with no ticket context prompting a
requirements check. Zero references anywhere in scope means no toggle
applies — this section doesn't fire.

Downgrade to **Warning** or **Suggestion** only when:

1. For a **per-ticket review**: the ticket's own documented
   requirements/AC establish a specific, concrete reason the omission is
   intentional (e.g., a bug fix to pre-existing, already-live code filed
   under the same Feature). This is never a live negotiation — the ticket
   text is the source of truth; if the developer disagrees, they update
   the ticket and a later review reads the updated text.
2. For a **Feature-level review**: the interactive gate
   (`./rules/code_review/feature_review_interactive_ux.md`) surfaces
   and verifies that same kind of reason.

And only if leaving it unwrapped creates no functional or usability problem
— both toggle states stay fully coherent per
[`../architecture/feature_toggle.md`](../architecture/feature_toggle.md)'s
"both paths must work" rule. See "Severity assessment is 's judgment"
above — a downgrade under this section follows that same standard.

## Focus On

- Security vulnerabilities (SQL injection, XSS, auth issues, secrets exposure)
- Bugs and incorrect behavior
- Design pattern violations (per loaded guidelines)
- Performance issues (N+1 queries, memory issues, unbounded operations)
- Missing error handling
- Test coverage gaps for new code
- Requirements gaps (when ticket context is provided)
- Feature Toggle coverage gaps (see Feature Toggle Coverage above)

## Do NOT Comment On

- Minor style issues that Pronto E/F errors already catch
- Code that wasn't changed in this branch
- Suggestions that would significantly expand scope
- Alternative approaches that aren't meaningfully better

## Static Analysis (Pronto) W/I Issues

**Ignore W/I warnings that are:**
- Line length for URLs or long strings
- Class/method length for inherently large domain models
- Complexity in inherently complex operations
- Duplication that's intentional
- Issues in code not changed in this branch

**Flag W/I issues that indicate:**
- Methods/classes that should genuinely be split
- Missing abstractions
- Code that will be hard to maintain
- FeatureEnvy smells — indicates logic that should live in the domain model

## Quality Mandate

Before reporting ANY AI-assessed issue, verify that it:
1. Does not violate ANY instruction in this document
2. Accurately describes the ACTUAL code (not assumed or hallucinated behavior)
3. Is not prohibited by the "What NOT to Comment On" rules

It is better to report zero AI issues than to report one that violates these instructions.

**Explain principles, don't cite documentation.** When flagging guideline violations,
explain the underlying principle and why it matters in practical terms. Do NOT reference
specific documentation files or line numbers.

## Issue Categories

| Category | Description |
|----------|-------------|
| security | Security vulnerability or risk |
| functional | Bug or incorrect behavior |
| performance | Performance issue or optimization |
| design | Design pattern or architecture concern |
| style | Code style or readability |
| test | Test coverage or quality |
| documentation | Documentation or comments |

## Related

- [advisory_findings.md](advisory_findings.md) — the Feature-level review
  pipeline's separate, opt-in category for judgment calls (intent gaps,
  usability, consistency, spec critique). Does not change the rules above —
  this file's "What NOT to Comment On" bar is unchanged for the per-ticket
  review. Also defines how a Feature Toggle Coverage finding is treated
  there (Known Issue by default, not automatically advisory).
- [`../architecture/feature_toggle.md`](../architecture/feature_toggle.md)
  — the toggle-integration rules Feature Toggle Coverage checks against.

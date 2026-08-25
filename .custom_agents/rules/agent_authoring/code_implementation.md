---
last_reviewed: 2026-05-19
---

# Code-implementation shared rules

Conventions every code-implementation agent inherits. Read by `code_business_logic.md`, `code_api.md`, `code_ui.md`, and `code_background_job.md`. Each area-specific agent layers its own placement, references, and "Do NOT" lines on top of this shared base.

## Scope and constraint

Code agents implement method bodies, add private helpers, and make working code. They do NOT create new classes or define new public interfaces — those belong to the Architecture and Design agents.

**Universal "Do NOT" list for every code agent:**

- Do NOT add new public methods. Return `NEEDS_DECISION` asking the Design agent to define them.
- Do NOT create new classes or files. Return `NEEDS_DECISION` asking the Architecture agent.
- Do NOT create new routes or migrations without explicit request. Return `NEEDS_DECISION`.
- Do NOT modify tests to make them pass — that's a Test-agent concern; fix the implementation.

If you encounter `TODO(Design)` markers (instead of `TODO(Code)`), the Design step was skipped incorrectly. Return `NEEDS_DECISION` — the Design agent needs to run first.

## What every code agent can create

- Implementation inside existing method stubs
- Private helper methods
- Constants for repeated literals / configuration
- YARD documentation comments (see below)

## Implementation guidelines (universal)

- **Read before writing.** Always read the full file before modifying it.
- **Match existing style.** Follow the patterns already used in the file.
- **Guard clauses.** Early returns for preconditions; flat code over deep nesting.
- **Error handling.** Handle errors at appropriate boundaries; don't swallow exceptions silently.
- **No over-engineering.** Implement what's needed, nothing more.
- **Constants for magic values.** Extract repeated literals into named constants.

## YARD documentation

Apply YARD per `./rules/yard/README.md` to every public method you write or modify. Code agents transcribe the `TODO(Code)` contract comment (which Design wrote) into full YARD tags — name each parameter's type, the return type, raised exceptions when relevant.

When adding or modifying an entry-point class for a feature documented under `docs/features/`, also apply the `@see` tag and verify the bidirectional `@see` ↔ `paths:` link per [`./rules/yard/cross_references.md`](../yard/cross_references.md).

The class-level YARD docstring stays as-is (Architecture wrote it); you may extend it if the implementation reveals an additional responsibility worth documenting.

## NEEDS_DECISION protocol

Every code agent uses the protocol in `./rules/agent_authoring/needs_decision.md`. Examples specific to code agents:

- `NEEDS_DECISION: Need to add a new public method for X — can Design Agent define it?`
- `NEEDS_DECISION: This method needs to call ExternalService — is there an existing wrapper?`
- `NEEDS_DECISION: The TODO says "encrypt data" — which encryption method?`
- `NEEDS_DECISION: Need a new route for X — should Architecture define it?`

Do NOT guess at public interfaces. Return `NEEDS_DECISION` and wait.

## Database migrations (when relevant)

When creating a new migration file, **always run `date +%Y%m%d%H%M%S` to get the correct timestamp.** Do not guess or hardcode the timestamp — AI models do not reliably know the current date/time. The migration file itself can be created manually or via `rails generate migration` — either is fine. If using a generator and the result needs modifications (additional columns, index changes, etc.), edit the generated file directly rather than re-running the generator.

## Feature toggles (when the plan specifies one)

When the implementation plan specifies a feature toggle strategy, read `./rules/architecture/feature_toggle.md` for full instructions on the `PlanSource::FeatureToggle` gem. **Critical:** Check whether the toggle already exists before creating a new one — the toggle name should be documented in the ticket. If the plan says to use a feature toggle but no toggle name is specified, return `NEEDS_DECISION`.

## Universal reference reads

Every code agent reads these shared rules. Area-specific agents add their own on top:

- `./rules/style/README.md` — code style rules
- `./rules/style/replica_reads.md` — replica read guidelines (when writing AR queries)
- `./rules/security/README.md` — security principles
- `./rules/workflows/legacy_code.md` — modifying code that doesn't meet current guidelines
- `./rules/yard/README.md` — YARD documentation rules (authoring + cross-references)
- `./rules/agent_authoring/self_survey.md` — self-survey mechanics (see below)

See `./rules/agent_authoring/documents_allowlist.md` for why the allowlist matters.

## Self-survey (before returning)

Before writing the Output Format summary below, answer the fixed
self-survey questions per `./rules/agent_authoring/self_survey.md`
and write them to `[workspace]/self_survey/{timestamp}_{agent}.md`.

## Output format (universal)

```
## Implementation Summary

### Files Modified

| File | Changes | Notes |
|------|---------|-------|
| [path] | [what was implemented] | [any notes] |

### Private Methods Added
- [method] in [class] — [purpose]

### Constants Added
- [CONSTANT] in [class] — [value and purpose]

### TODO(Test) Notes
[Test cases or scenarios the Test agent should cover]

### Questions / NEEDS_DECISION
[Any issues that need resolution]
```

Area-specific agents may extend this format (e.g. UI adds view-specific notes; API adds a list of before-actions) but should not remove fields.

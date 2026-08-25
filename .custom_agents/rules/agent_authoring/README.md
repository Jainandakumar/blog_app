---
last_reviewed: 2026-05-19
---

# Agent-authoring rules

Shared patterns that recur across subagent files (`./agents/<name>.md`). These are Mode A (explicit read) — they are loaded only by the `/author` skill and by anyone manually editing or operating as a subagent.

## Contents

- [critical_constraints.md](critical_constraints.md) — the CRITICAL CONSTRAINTS section pattern: scope statement + "Do NOT" list + Why.
- [documents_allowlist.md](documents_allowlist.md) — the "for guidelines, read ONLY these docs" pattern: explicit-read enforcement at the agent-file level.
- [needs_decision.md](needs_decision.md) — the `NEEDS_DECISION: …` return-value protocol for escalation when a question falls outside the agent's allowlist.
- [code_implementation.md](code_implementation.md) — shared rules every code-implementation agent inherits (Do NOTs, YARD, migrations, feature toggles, universal reference reads, output format).
- [workspace_output.md](workspace_output.md) — write the artifact to `[workspace]/X.md`, return a 3-5 line summary; what goes in the file vs the summary.
- [research_confidence.md](research_confidence.md) — confidence levels (Confirmed/Likely/Uncertain/Unverified), the verification principle, source priority, and the avoid-list for any research-producing agent.
- [codebase_exploration.md](codebase_exploration.md) — shared exploration strategy for research-style agents: how to use Glob/Grep/Read, depth tiers by task, what not to do during exploration.
- [compaction_recovery.md](compaction_recovery.md) — orchestrator pattern for resuming when a subagent compacts mid-run.
- [touched_files.md](touched_files.md) — `.-touched-files` format and cleanup protocol shared by skills that modify source files.
- [self_survey_questions.md](self_survey_questions.md) — the fixed self-survey question list, kept separate so it's easy to browse without the delivery mechanics.
- [self_survey.md](self_survey.md) — self-survey mechanics: when it fires, where answers go, frontmatter format, secrets/PII handling.

## When to read this folder

- Authoring a new subagent file in `./agents/`.
- Updating an existing subagent file when the role's scope changes.
- Operating the `/author` skill's audit pass over agent files.

## Related

- `../meta/instruction_authoring.md` — overarching conventions for skills, agents, and rules.
- `../meta/frontmatter_specs.md` — frontmatter schemas (including for agent files).
- `../communication.md` — universal communication rules every agent obeys.

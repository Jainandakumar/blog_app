---
last_reviewed: 2026-05-26
---

# Tool-call budget

The recurring "Budget" section pattern in agent files. Subagents that
exhibit cycling — exploring far more than the task warrants, returning
after many minutes of work that should have taken under a minute — carry
a Budget section that gives them a target tool-call count and a
fallback when the budget is exhausted.

## Purpose

A subagent that doesn't know when to stop will keep grepping, reading,
and re-reading until it either compacts or returns a sprawling result.
For pattern-matching work (find similar code, identify the relevant
file, classify an issue), the right answer is usually visible after 5-15
tool calls. Beyond that the agent is thrashing.

The Budget section makes the convergence point explicit: at the budget
limit, return what you have and stop. Don't keep searching for a more
perfect answer.

This is **guidance, not enforcement.** The agent can ignore it. In
practice Sonnet honors it well; Opus is more likely to push past it on
its own initiative. Pair the Budget section with model selection
appropriate to the task (per the subagent's frontmatter) — Sonnet for
budgeted work, Opus only when deep exploration is genuinely the job.

## Shape

```markdown
## Budget

Target: ~N tool calls, ~M minutes of work.

If you haven't converged by the budget limit, return what you have
along with a brief note about what's still unknown. Do NOT keep
searching for a more complete answer past the limit — partial
findings with a clear "what's missing" line is more useful to the
orchestrator than a long, fully-explored result that arrives after a
compaction.
```

## Rules for content

- **Pick budgets from observed work, not from intuition.** If an agent
  routinely converges in 8 tool calls, set the target to 10-12 (a little
  headroom). If it routinely needs 25, that's the target.
- **Always include the fallback.** "What if I hit the budget?" must
  always be answered: return partial + note what's missing. Without the
  fallback, the agent doesn't know whether to truncate, retry, or fail.
- **Specify "tool calls" not "tokens" or "context."** Agents have no
  reliable visibility into their token usage. Tool calls are countable
  and observable.
- **A wall-clock estimate is optional** but useful as a sanity check
  for human reviewers reading the agent file. If you include one, make
  it a range (~3-5 minutes) not a precise number.

## When to use

- Research-style agents that explore the codebase or web sources to
  produce findings: `research`, `planning_research`,
  `planning_external_research`, `validate`.
- Triage agents that classify input and produce a fix plan: `evaluate`,
  `spike_plan`.
- Brief authoring agents where excess exploration adds little: a brief
  is bounded by the spec already.

## When NOT to use

- **Code-implementing agents.** `code_business_logic`, `code_api`,
  `code_ui`, `code_background_job`, `architecture`, `design`, `test`,
  `document_yard` — these have a definite job (implement the methods,
  write the specs, apply YARD). They're done when the work is done; the
  number of tool calls scales with file count and complexity, not with
  exploration depth. A budget here would either be unenforced (because
  the work is real) or harmful (because it cuts off legitimate
  implementation).
- **Agents that orchestrate user dialogue.** `interactive_debug`,
  `setup_check` — they wait on user input; tool-call counts don't
  reflect their progress.
- **Spike research.** `spike` is the agent whose explicit purpose is
  to spend the time. A budget contradicts the scope.

## Why guidance, not enforcement

 Code does not expose a per-subagent tool-call cap, wall-clock
timeout, or thinking-token budget in frontmatter today. The
orchestrator can't interrupt a subagent mid-run — the Agent tool is
synchronous and returns only when the subagent finishes.

Given that, the realistic levers are:

1. **Model selection** (frontmatter) — Sonnet cycles less than Opus on
   simple tasks. Set this first.
2. **Prompt-level scope** — passing fewer files, narrower questions,
   tighter return contracts.
3. **The Budget section** — explicit "stop and report partial" rule the
   agent can apply itself.

Budgets are layer 3 of that stack. Layer 1 (model) is the biggest lever
and should be set correctly before reaching for layer 3.

## Reporting

When an agent applies its budget (returns partial because the limit
was hit), the return summary should say so explicitly:

```
Findings written to [workspace]/research.md (partial — budget reached
after 12 tool calls). Still unknown: <one line of what's missing>.
```

The orchestrator can then decide whether to relaunch with a narrower
scope, accept the partial result, or surface the gap to the user.

## Related

- [`workspace_output.md`](workspace_output.md) — the workspace-output
  pattern; budget partials write the same way as full results.
- [`compaction_recovery.md`](compaction_recovery.md) — what happens when
  a subagent compacts instead of honoring a budget. A budget is the
  preferred path; compaction recovery is the fallback when an agent
  ignores the budget and keeps thrashing.
- [`documents_allowlist.md`](documents_allowlist.md) — the
  Reference-reads pattern; reference this rule from an agent file's
  allowlist when applying it.

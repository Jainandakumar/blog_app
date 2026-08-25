---
last_reviewed: 2026-07-14
---

# Interactive UX for /develop

How `/develop` communicates in `interactive` and `guided` modes. The pipeline
logic is unchanged by this file — it governs **voice** and **message timing**
so the user feels in control and the collaboration reads as a collaboration.

Applies to `interactive` and `guided` only. `auto` / `headless` post status
to external interfaces per [`pipeline_modes.md`](pipeline_modes.md) and do not
use these messages.

## Principles

1. **Collaborative voice, not confirmatory voice.** "Here's what I'm thinking
   — does this match what you want?" not "I know what to do; confirm so I can
   proceed." The user is a partner, not a rubber stamp.
2. **Messages live at pauses.** A message printed before a long silent stretch
   scrolls out of view and is missed. Put the load-bearing message *at* the
   pause where the user must act — not before the work that precedes it.
3. **Re-orient at every pause.** Each gate is self-contained: where we are,
   what just happened, what's next, and what the user can do right now. Never
   assume the user still sees an earlier message.
4. **Demystify the process.** The user's default mental model is "approve all
   the code before it's written." Say plainly that stubbing skeletons is *part
   of planning* — reversible scaffolding, not the code being committed — and
   that they can redirect at the gate.

## Start orientation (non-blocking, once at the top)

Print this at the start of the run (interactive and guided); do **not** pause
on it.

> **Starting the development process for [TICKET_KEY].**
>
> **Here's an overview of the process sequence:** I'll read the ticket, form a
> plan, and stub the classes and method signatures to confirm the approach.
> This helps me formulate a functional plan and surface any issues *before* we
> start writing code — **no real code is written yet.** (You may see me create
> or edit a few skeleton files along the way; that's the stubbing — planning
> scaffolding I can revise or revert freely — not the implementation.)
>
> Then I'll **stop and review the plan with you** before implementing. After
> that: build → test → review → **stop again before I commit.** You're in
> control at each stop, and you can ask me anything.

Fill `[TICKET_KEY]` with the ticket (e.g. `MDP-236636`, or the `LOCAL-` key).
The stub explanation is deliberately here, up front: in interactive mode
Architecture and Design write skeleton files during Steps 6–7, so the user may
see file-edit prompts *before* the Plan Review gate — this frames them as
planning, not implementation.

## Plan Review gate (interactive only — the load-bearing message)

Printed at the Plan Review pause (after Design, before Code). The
implementation summary lives in `[workspace]/implementation_summary.md`
(written by the `plan_summary` agent); present its highlights inline.

> I've read the ticket and worked out a plan. **To pressure-test it, I stubbed
> the classes and method signatures — nothing is implemented yet.** Here's what
> I intend to build:
>
> [summary highlights: classes touched, key public methods + what each does,
> files affected]
>
> Ask me anything — I can walk you through any stubbed file (they're on disk
> now, e.g. `app/models/.../foo.rb`). When you're ready: **Proceed** (I
> implement) · **Revise** (tell me what to change and I'll re-plan) · **Stop**.

Handle the reply as an open dialogue in the orchestrator context. Three shapes
of response are expected:

1. **No feedback / quick review → Proceed.** The user glances and approves (or
   approves without reading). Continue to Code.
2. **Questions, no change → answer, then Proceed.** Answer from the stubs /
   `plan.md` / `research.md`. Understanding only; the plan is unchanged.
3. **Change requested → Revise.** Ranges from a minor plan tweak to a new
   requirement the ticket never captured (the user knows something that isn't
   written down). Handle per the Revise rules below, then **repeat this gate**
   with the updated plan.

### Revise handling

- **Plan tweak (no new requirement):** update `plan.md`, re-run Architecture /
  Design as needed, re-present.
- **New or changed requirement** (revealed now, not in the ticket): fold it
  into the requirements the pipeline carries (`requirements` / `criteria` in
  structured context, and the workspace requirements record), then re-plan
  (update `plan.md`, re-run Architecture / Design) and re-present. Because this
  is a **requirement change**, it is **documentation** — record it so it posts
  to Jira per the General rules in
  [`../../skills/develop/pipelines/develop.md`](../../skills/develop/pipelines/develop.md)
  and the status-vs-documentation rule in [`pipeline_modes.md`](pipeline_modes.md).
  A requirement revealed only at review can't be verified against the ticket —
  say so when you document it.

Continue to Code only on **Proceed**.

## Review-findings and Commit gates (interactive)

Same pattern — restate context, use the collaborative voice, offer clear
options. The Commit & push gate shows the diff/summary and names what (if
anything) will be recorded in Jira as **documentation** (per the
status-vs-documentation rule in [`pipeline_modes.md`](pipeline_modes.md)).

## Guided mode

Guided skips the Plan Review gate and runs to the Commit & push gate. Give it
a **lighter** version of the same collaborative re-orientation — one short
paragraph: what was built, what will be recorded in Jira, what push does, then
confirm.

## Related

- [`pipeline_modes.md`](pipeline_modes.md) — the four modes, gate lists, and
  the status-vs-documentation routing rule.
- [`../../agents/plan_summary.md`](../../agents/plan_summary.md) — produces the
  implementation summary shown at the Plan Review gate.

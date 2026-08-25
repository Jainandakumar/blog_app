---
last_reviewed: 2026-08-03
---

# Interactive UX for the Feature-level review

How the `feature_review_instructions.md` orchestrator runs the pre-flight
gate between the drafted report and posting anything. Mirrors
`./rules/develop/interactive_ux.md`'s collaborative-voice pattern,
scoped to this one gate. Applies to `interactive` and `guided` only —
`auto` / `headless` skip this entire gate and post the draft as-is (per
`./rules/develop/pipeline_modes.md`).

## The one rule that governs everything here

**Reclassification changes framing, never presence.** The gate can move a
finding between Known Issues and Advisory Findings based on what the user
says, but it can never remove a finding from the report. "We knew this
would be broken" is grounds for moving an item to Advisory with that
context noted — it is never grounds for deleting it. The review's whole
point is "here's every gap, fully documented"; an item the user is
already aware of still belongs in the report, with an existing ticket
referenced if there is one.

## Opening the gate

Print once, non-blocking is not appropriate here — this gate blocks until
the user is done, unlike a routine confirmation:

> I've finished reviewing [FEATURE_KEY]. Before anything gets posted to
> Jira or any ticket is touched, let's go through what I found — this is
> interactive: ask me about any item for more detail, tell me if I've
> got something wrong, or add context I didn't have. Nothing posts until
> you're satisfied.
>
> **Completeness:** [verdict]. **[N] Known Issues, [N] Advisory Findings.**
> Full draft: `.workspace/[FEATURE_KEY]/feature_review_report.md`.
>
> [top 3 most severe Known Issues, one line each]

## During the conversation

- Answer questions about any item by reading the full draft — the user
  is looking at a summary, you have the whole file.
- If new context changes a finding's *facts* (not just its framing —
  e.g. the user reveals a related fix already merged elsewhere), that's
  not a reclassification, it's new information: re-verify against the
  relevant `coverage_batch_*.md` evidence before changing anything, and
  say if you can't confirm it from the workspace alone.
- If the user disputes an item outright as simply wrong (not "expected,"
  but factually incorrect), verify against the cited evidence before
  agreeing to change it — same standard as any other correction.

## Applying a reclassification

When the user says something matching the "known/expected" pattern for a
specific Known Issue:

1. Edit `[workspace]/feature_review_report.md` directly: move that item's
   checklist line + its Known Issue Detail entry out of Known Issues,
   into a new Advisory Finding using `advisory_findings.md`'s output
   shape (what  noticed / why advisory / what it might mean),
   folding in the user's context as the reasoning.
2. Drop its "Prompt for " box — Advisory items never get one.
3. Renumber the remaining Known Issue checklist lines/Details so they
   stay sequential.

The reverse (Advisory → Known Issue, because the user confirms it's a
real problem) works the same way: move it, add severity/category, add a
Prompt for  box, renumber.

## Closing the gate

Once the user has no more feedback, confirm before moving on:

> Anything else before I post this to [FEATURE_KEY]? Once you're good,
> I'll post the checklist, then ask about creating or updating tickets
> for the Known Issues.

Only proceed to posting (`feature_review_instructions.md` Step 6) after
an explicit go-ahead — this is the one place in the pipeline where
silence isn't consent, because the whole point of the gate is that the
user actively reviewed the content.

## Related

- `./rules/develop/interactive_ux.md` — the pattern this mirrors.
- `./rules/code_review/advisory_findings.md` — the categories and
  output shape a reclassified item must use.
- `./skills/code-review/feature_review_instructions.md` — where
  this gate sits in the pipeline (Step 5, between synthesis draft and
  posting).

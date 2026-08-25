---
last_reviewed: 2026-05-19
---

# Troubleshooting & Recovery rules

Explicit-read rules for when an agent (including the main session) encounters
difficulty completing a task. Not universal — read these when the symptoms below
appear, not on every session.

## When to read these

Read the relevant file immediately if you notice ANY of these signals:

1. The user says "that's not what I want" multiple times
2. The user seems frustrated or confused
3. Multiple iterations without acceptance
4. The user explains the same thing different ways
5. You're confident you did it right, but the user says it's wrong

**Critical threshold:** dissatisfaction 2-3 times in a row → STOP and read.

## Quick Reference

| Situation | Read |
|---|---|
| User says "that's not right" but you think you did it correctly | [misalignment.md](misalignment.md) |
| You need information/decisions to proceed | [blocked.md](blocked.md) |
| A specific problem (tests failing, unclear requirements, environment issue) | [scenarios.md](scenarios.md) |
| Reading a screenshot or video frame of the  app and need to identify user/client/error landmarks | [ui_landmarks.md](ui_landmarks.md) |

## Core principles

### Stay solution-oriented

Always move forward. Focus on what you CAN do, what information you need, what
alternatives exist.

### Take ownership of confusion

- "I'm not sure I understand X correctly" (not "You didn't explain X")
- "Let me clarify what you need" (not "You need to tell me more")

### Be transparent about limitations

State what you don't know. Explain why something is difficult. Propose
workarounds.

## Communication strategies

### Ask specific questions

- Bad (vague): "Can you give me more details?"
- Good (specific): "Should the enrollment effective_date be validated against the plan's coverage period, or can it be any future date?"

### Offer specific options

- Bad: "What should I do?"
- Good: "Option A — service object (more testable, adds a file). Option B — model callback (simpler, harder to test). Which fits better?"

### Show progress even when stuck

> I've completed:
> - Database migration
> - Model validations
>
> I'm blocked on:
> - Notification logic (need clarification)

## Recovery patterns

1. **Ask-Propose-Proceed.** Ask a specific question; propose what you'll do while
   waiting; proceed with the proposed action.
2. **Hypothesis-Test-Adjust.** State your hypothesis; test it (build a small
   piece); show the user and adjust.
3. **Show-Don't-Tell.** When stuck explaining, stop and write example code
   showing what you mean; ask if that's correct.

## What NOT to do

| Don't | Instead |
|---|---|
| Argue or debate | "I see a potential issue… would you like me to implement it anyway or consider an alternative?" |
| Give up | "This is more complex than I thought. Let me break it down into smaller pieces." |
| Blame the user | "I made an assumption about X that turned out to be wrong." |
| Get stuck in analysis paralysis | "I'm going to start with the simple approach. We can refine it." |
| Repeat the same mistake | "I made this mistake earlier. Let me search for all similar instances and fix them at once." |
| Leave things broken | Debug it or ask for help if truly stuck. |

## When to suggest `/compact`

**Do suggest:** after 15-20 exchanges without completion, after a major milestone,
after multiple failed attempts at the same problem, when the conversation has
pivoted significantly.

**Don't suggest:** when making steady progress, mid-debug, when the user just
asked a follow-up question, less than 10 exchanges in.

## Success metrics

- User stays engaged
- Consistent forward progress
- Misunderstandings quickly identified and corrected
- Conversation stays solution-focused

If warning signs appear (user repeats themselves, same error keeps happening,
conversation goes in circles): explicitly reset.

> Let me reset. I think we're getting stuck in [issue].
> Here's what I'm going to do to move us forward: [concrete action].

---
last_reviewed: 2026-05-19
---

# The misalignment problem

When the user indicates dissatisfaction but you believe you completed the task
correctly.

## Understanding the gap

**The most common problem isn't that you failed — it's that you succeeded at
the wrong thing.**

What happens:

1. The user has a clear mental picture of what they want.
2. The user describes it (often briefly, because they see it clearly).
3. You interpret the description, filling in gaps with assumptions.
4. You successfully build what you understood.
5. The user sees the result and says "that's not what I meant."
6. You think "but I did exactly what they asked" — and you did.

**The gap:** the user's mental model ≠ your interpretation of their words.

This is nobody's fault. Communication is hard, especially when one person can
see the end result and the other can't.

## Detecting misalignment

Signs you're in this situation:

- You believe you completed the task correctly
- Tests pass, code works, no errors
- You followed the requirements as stated
- The user says "no, that's not right"
- The user seems frustrated even though you "fixed" it
- You've iterated 2-3 times but still not hitting the mark

**Key indicator:** when the user's dissatisfaction doesn't match your confidence
in your work, there's a fundamental misunderstanding about the desired outcome.

## The reset pattern

When you detect misalignment, use this pattern:

```
I notice we've gone through a few iterations and I'm still not delivering what you want. I think there might be a gap between what I'm understanding and what you're envisioning.

Let me reset and verify my understanding:

Here's what I heard:
- [Summarize the task as you understand it]
- [List key requirements you interpreted]
- [State assumptions you made]

Here's what I built:
- [Describe the actual behavior/output]
- [Explain your reasoning for key decisions]

Here's where I might be wrong:
- [Identify areas where you made assumptions]
- [Point out ambiguities you filled in yourself]

Can you help me understand:
- What specific behavior/output are you expecting?
- What am I doing that you don't want?
- What am I NOT doing that you do want?

If it helps, could you:
- Show me an example of what the result should look like?
- Point to existing code that behaves the way you want?
- Describe the user journey or workflow you're imagining?
```

## Worked example

**Scenario:** the user asks you to "add pagination to the users list."

**What you built:** page numbers at the bottom (1, 2, 3, 4, 5…).

**What they wanted:** infinite scroll that loads more users as you scroll down.

Both are valid interpretations of "pagination."

**The reset:**

> I've added page-number pagination at the bottom of the users list, but I'm
> sensing that's not what you wanted.
>
> When you said "add pagination," I interpreted that as traditional page
> numbers. But I think you might be envisioning something different.
>
> Are you looking for:
> - Traditional page numbers (what I built)
> - Infinite scroll (load more as you scroll)
> - "Load More" button
> - Something else entirely?

## Recovery options

1. **Start fresh (recommended).** Scrap the current approach and build it right.
2. **Show, don't tell.** Build a quick prototype of what you think they want —
   rough but enough to verify direction.
3. **Request clarification with context.** Share the next steps in detail and
   ask "Does that match what you're envisioning? If not, catch me now before I
   build the wrong thing again."

## Preventing misalignment

Before starting work:

1. **Restate the task in your own words.** "Let me make sure I understand: you
   want [description]. Is that correct?"
2. **Identify ambiguities upfront.** "I see a few ways to interpret this. Are
   you looking for A or B?"
3. **Share your mental model early.** "I'm thinking I'll approach this by
   [approach]. Does that align?"
4. **Build iteratively with checkpoints.** "I've built the basic structure.
   Does this look like we're heading in the right direction before I add
   details?"

## When to suggest starting fresh

Consider it when:

- The conversation has gone in circles 3+ times
- You've built significant code in the wrong direction
- The user seems more confused after each iteration
- You realize your core assumptions were wrong

```
I think we've gotten off track, and continuing to iterate on the current code might be confusing things further.

Would you be open to me starting fresh with a clearer understanding? I can:
1. [Describe new approach based on correct understanding]
2. Build it cleanly from scratch

The current code isn't helping us get to the right solution. Sometimes starting clean is faster than debugging a misunderstanding.
```

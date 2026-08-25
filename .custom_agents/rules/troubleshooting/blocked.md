---
last_reviewed: 2026-05-19
---

# When you're blocked

Being blocked doesn't mean stopping. It means being transparent about constraints
and proposing alternative paths forward.

## Identify the blocker type

Before responding, identify WHAT is blocking you:

- "I haven't thought of the right approach yet" → keep trying, you're NOT blocked.
- "I need information that doesn't exist in the codebase" → communicate the gap (Type 1).
- "This requires a decision between conflicting requirements" → present tradeoffs (Type 2).
- "This is technically impossible with current constraints" → propose alternatives (Type 3).
- "User insists on impossible approach" → re-explain and ask about underlying goal (Type 4).

## Response pattern

```
[State the constraint clearly]

**Here's what I recommend:**
[Your recommendation for how to resolve or work around this]

**Alternative approaches we could explore:**
1. [Alternative that changes a constraint]
2. [Alternative that achieves similar outcome differently]
3. [Alternative that delivers partial value]

Which direction makes sense for your situation?
```

## Type 1: Missing information

You need information that isn't available (API docs, requirements, context).

```
I can't proceed with [task] without [specific information] because [why required].

**Here's what I recommend:**
- Check for related tickets — is there a parent epic with this context?
- Check code ownership — the code in [file/area] is owned by [names from CODEOWNERS].
- Check with Product Owner if this is about requirements/business rules.

**Alternative approaches:**
1. Stub the integration now — build structure with placeholder, fill in when docs arrive.
2. Reverse-engineer from existing code — model it after [similar code in X].
3. Build without this feature — deliver the rest now, add this piece in follow-up.
```

## Type 2: Conflicting requirements

Requirements conflict, or multiple valid approaches with different tradeoffs.

```
I've identified a conflict: [Requirement A] and [Requirement B] cannot both be satisfied because [technical reason].

**The tradeoff:**
- **Option A — prioritize X** → achieves [] but sacrifices [costs]
- **Option B — prioritize Y** → achieves [] but sacrifices [costs]

**Here's what I recommend:**
[Your recommendation based on codebase patterns, performance, maintainability]
- Why: [specific reasoning]
- Supporting evidence: [similar code in Z uses this approach]

**If you're uncertain:**
- Product Owner can clarify business requirements
- Team Lead can clarify technical architecture
- Code Owner [name] built the related system

Which option aligns better with the project goals?
```

## Type 3: Technical impossibility

The request is technically impossible due to external constraints.

Phrase the message per `./rules/communication.md` § "Technical infeasibility".

```
[Requested outcome] isn't technically feasible with [current constraint] because [specific technical reason].

**Why this is a constraint:**
[Clear explanation — math, physics, architecture]

**Here's what I recommend exploring:**
[How to change or work around the constraint]

**Alternative approaches that might achieve your goal:**
1. [Alternative that relaxes the constraint]
2. [Alternative that changes the architecture]
3. [Alternative that redefines the problem]

What's driving the requirement for [original constraint]? There might be other ways to achieve your underlying goal.
```

## Type 4: User insists on impossible approach

You've explained the constraint, proposed alternatives, and the user still insists.

```
I understand you want [impossible thing]. I want to be completely clear about why this can't work so you can make an informed decision:

[Very clear, specific technical explanation]

**This means:**
- If I attempt to implement this as specified, [specific bad outcome]
- This isn't a limitation of what I can code — it's a limitation of [physics/hardware/architecture]

**I genuinely want to help you achieve your goal. Let's focus on what you're trying to accomplish:**
- What problem are you solving with [impossible requirement]?
- What would "success" look like for your users?

Understanding your underlying goal would help me propose solutions that CAN work.
```

## Key principles

1. **Never frame as AI limitation unless it truly is.** "This code can't do X" not "I can't do X".
2. **Always propose alternatives** — even when blocked, suggest 2-3 different paths.
3. **Stay solution-focused.** "Here's what we CAN do" not "This is impossible."
4. **Ask about underlying goals.** The user might be locked into an approach; understanding the goal unlocks alternatives.
5. **Recommend resources.** Code owners, team leads, product owners who can help.

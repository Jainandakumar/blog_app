# Step 8: Code

**Always runs.**

## Dispatch by file area

Group the files-to-modify list by area. For each non-empty area, launch
one code agent.

| Files match | Launch agent |
|---|---|
| `app/models/**`, `app/validators/**` | `./agents/code_business_logic.md` |
| `app/controllers/**`, `engines/api/app/controllers/**`, `app/serializers/**` | `./agents/code_api.md` |
| `app/views/**`, `app/helpers/**`, `app/assets/**` | `./agents/code_ui.md` |
| `lib/job_*.rb`, `lib/processor*.rb` | `./agents/code_background_job.md` |

If a single ticket spans multiple areas, launch the agents sequentially
(business logic first so services exist when controllers/jobs call
them).

For each area:

```
"Read `./agents/<code_AGENT>.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Files in your scope: [LIST OF FILES IN THIS AREA]
Local overrides: [relevant items from LOCAL.md]

Implement all changes in your area. Replace TODO(Code) markers with
working code. Read existing files before modifying them.

Apply YARD per `./rules/yard/README.md` to public methods you write or
modify."
```

## NEEDS_DECISION routing

If a Code agent returns NEEDS_DECISION:

- **Needs new public methods** → relaunch the Design agent (Step 7)
  with the request, then relaunch the same Code agent with the updated
  design.
- **Needs new classes/files** → relaunch the Architecture agent
  (Step 6), then Design, then the same Code agent.
- **Needs new routes or migrations** → ask the user (these are outside
  the agent chain).

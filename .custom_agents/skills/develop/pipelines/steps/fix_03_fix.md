# Fix Step 3: Fix

**Skip when:** nothing to fix.

## Dispatch by file area

Group the RED items in `[workspace]/evaluation.md` by the file area
each issue touches. For each non-empty area, launch one code agent.

| Files match | Launch agent |
|---|---|
| `app/models/**`, `app/validators/**` | `./agents/code_business_logic.md` |
| `app/controllers/**`, `engines/api/app/controllers/**`, `app/serializers/**` | `./agents/code_api.md` |
| `app/views/**`, `app/helpers/**`, `app/assets/**` | `./agents/code_ui.md` |
| `lib/job_*.rb`, `lib/processor*.rb` | `./agents/code_background_job.md` |

For each area:

```
"Read `./agents/<code_AGENT>.md` for your instructions.

Fixes to make: read [workspace]/evaluation.md — apply only RED items
from the Fix Plan that touch files in your area: [LIST OF FILES IN
YOUR AREA].
Local overrides: [relevant items from LOCAL.md]

Rules:
- Only fix listed issues — no refactoring
- Read files before modifying
- Fix implementation, not tests (unless test is clearly wrong)
- Apply YARD per `./rules/yard/README.md` to public methods you modify

Return: files modified and what changed."
```

**If a Code agent returns NEEDS_DECISION:** report the issue to the
user — the fix pipeline does not have Architecture/Design agents. The
user may need to switch to the full develop pipeline or handle it
manually.

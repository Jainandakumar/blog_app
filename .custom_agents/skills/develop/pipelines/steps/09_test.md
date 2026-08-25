# Step 9: Test

**Always runs.**

Launch a general-purpose Agent:

```
"Read `./agents/test.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Write tests for all new/modified code. Run with `bundle exec rspec [file]`.
Write results to [workspace]/test_results.md (update after each test file run)."
```

## Retry loop

If tests fail, add `test_fix_attempts: 0` to structured context. Each
iteration:

1. For each failing spec, determine the source file under test and pick
   the code agent by area (see "Dispatch by file area" in
   `../develop.md` Step 8). For most fix loops the source file is a
   single area — launch one agent.

   ```
   "Read `./agents/<code_AGENT>.md` for your instructions.

   Failing tests: [list from test_results.md — file:line, error message]
   Source files under test: [LIST OF SOURCE FILES IN YOUR AREA]
   Context: [STRUCTURED CONTEXT]
   Local overrides: [relevant items from LOCAL.md]

   Fix only the failing tests in your area. Do not modify passing code
   or write new tests. Read the failing spec files to understand what
   is expected before making changes. Read existing source files before
   modifying them.

   Apply YARD per `./rules/yard/README.md` to public methods you modify."
   ```

   **If the Code agent returns NEEDS_DECISION:**
   - Needs new public methods → relaunch Design (Step 7), then Code,
     then re-run Test.
   - Needs new classes/files → relaunch Architecture (Step 6), then
     Design, then Code, then re-run Test.
   - Needs new routes or migrations → stop and report.
   - After any NEEDS_DECISION routing, reset `test_fix_attempts = 0`
     and continue.

2. Increment `test_fix_attempts`. Relaunch the test agent.

3. All tests pass → continue to Step 10.

4. Tests still fail and `test_fix_attempts < 3` → repeat from step 1.

5. `test_fix_attempts >= 3` → stuck flow below.

## Stuck flow

Present this report, then use `AskUserQuestion`:

```
## Test Failures: Unable to Resolve (3 attempts)

**Failing tests:**
[file:line — error message for each]

**Fix attempts:**
1. [what was changed]
2. [what was changed]
3. [what was changed]

I have not been able to resolve these failures and do not recommend
further automated attempts without additional context or a change in
approach.
```

Options:

- **Try Again** — reset `test_fix_attempts = 0`, reenter the loop.
- **Review the Problem With ** — launch the interactive debug
  agent (below), apply the fix plan, reset `test_fix_attempts = 0`,
  reenter the loop.
- **I'll Fix It Myself** — stop and report: "Development paused at Test
  step. Resume with `/develop [ticket] fix` after your changes."

### Launching the interactive debug agent

```
"Read `./agents/interactive_debug.md` for your instructions.

Problem: Test failures unresolved after 3 automated fix attempts.
Workspace: [workspace path]

Failing tests:
[file:line — error message for each]

Files modified during fix attempts:
[list of files the Code agent changed across all 3 attempts]

What was tried:
[summary of changes made in each of the 3 fix attempts]

Diagnose the root cause and write a fix plan to
[workspace]/debug_plan.md."
```

After it returns, group the files in the Fix Plan by area and launch
one code agent per area:

```
"Read `./agents/<code_AGENT>.md` for your instructions.

Apply the fix plan at [workspace]/debug_plan.md — implement the Fix
Plan exactly for files in your area: [LIST OF FILES IN YOUR AREA].
Context: [STRUCTURED CONTEXT]
Local overrides: [relevant items from LOCAL.md]

Read each file listed in the plan before modifying it."
```

Then reset `test_fix_attempts = 0` and reenter the retry loop.

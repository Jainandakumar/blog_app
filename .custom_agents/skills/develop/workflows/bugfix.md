---
last_reviewed: 2026-08-19
---

# AI bug-fixing guide

Detailed forensic process for AI agents fixing defects. Read this when the
ticket type is Bug (or when `/develop fix` is in play). General development
mechanics live under `./rules/workflows/`.

---

## 6-step forensic process

### 1. Identify what is broken

- Describe current behaviour vs. expected behaviour.
- You may or may not know the exact code location yet. Examples:
  - UI workflow doesn't produce the expected outcome (steps known, code
    unknown).
  - Test fails only on the 31st (reproducible with `travel_to`, but the
    *why* still needs locating).

### 2. Initial code research

- Start with what you know (controller action, failing test, etc.).
- Trace back to find the relevant code that does the work.
- Identify **where** the issue happens.

### 3. Identify documented behaviour (critical step)

- Find commits that created/updated the problem code:
  `git log --follow <file>`.
- Extract `MDP-NNNNNN` ticket numbers from commit messages.
- Ask the user to look up the ticket in Jira:
  `https://plansource.atlassian.net/browse/MDP-NNNNNN`.
- Ask the user to copy/paste or summarise the original requirements.
- Review **all** commits for that ticket:
  `git log --all --grep='\bMDP-123456\b'` (shows tests, other files —
  the `\b` anchors matter, since `MDP-1234` would otherwise also match
  `MDP-12345`).
- **Critical decision — is this a BUG or a NEW REQUIREMENT?**
  - **BUG.** Original requirements were missed / incorrectly implemented.
  - **NEW REQUIREMENT.** Original requirements were missing or unclear for
    this scenario.
  - This distinction affects whether to hot-patch to production.

**If the user says the ticket didn't describe the feature:**

- May need to look at previous tickets that updated this code.
- Ask: "Would you like me to find previous tickets that also updated this
  code? I can use `git log` to find them."
- Warning: this can expand scope significantly (90+ minutes of research).
  Get user confirmation before deep-diving.

### 4. Test assessment

- **For BUG only.** Are existing tests wrong (testing behaviour that doesn't
  match original requirements)?
  - If yes: document in the bug ticket, then update tests.
  - If no: expand tests to cover this case.
- **For NEW REQUIREMENT.** Expand tests to cover the new case.
- See [../../../rules/testing/philosophy.md](../../../rules/testing/philosophy.md)
  for the "tests document the guarantees we commit to" mental model.

### 5. Commit code changes

- Follow normal development process.
- Run Pronto on changed lines.
- Run related tests: `bundle exec bin/rspec-changed`.
- Ensure all pre-merge pipeline checks pass.
- If your fix touches a public method, apply YARD per
  [../../../rules/yard/README.md](../../../rules/yard/README.md).

### 6. Hot-patch assistance (BUG only)

- Offer: "This is a bug fix. Would you like help creating branches for the
  release branch and master?"
- If yes: follow [hotpatch.md](hotpatch.md).
- **On merge conflicts:**
  - If you understand the impact (whitespace, obvious): resolve it.
  - If code functions differently based on the choice and you lack evidence:
    stop and ask the user.

---

## When you discover a bug (not your current task)

If you discover a bug that's blocking your current task or is otherwise
significant:

### First — assess the situation

> "I've discovered a bug in [feature/code]. This is blocking/affecting [your
> current work].
>
> Options:
> 1. Fix it now (may take [estimate])
> 2. Create a bug ticket for prioritisation (if you have time to wait)
> 3. Partially fix what's needed, create ticket for full resolution (MUST do
>    both)
>
> Which would you prefer?"

### If the user chooses to create a bug ticket

Create a Jira bug ticket with:

- **(a) Short descriptive title.** Clear summary of the issue.
- **(b) Feature/code in question.** What component/area is affected.
- **(c) Expected outcome.** What should happen.
- **(d) Actual outcome.** What actually happens.
- **(e) How to recreate.** Console command, UI workflow, or reproduction
  steps.
- **(f) Additional details.** Method name, line of code, error messages,
  stack traces.

### After creating the ticket

> "I've created Jira ticket MDP-NNNNNN documenting this bug. Please coordinate
> prioritisation and assignment of this ticket with the technical lead."

### Important notes

- Don't create a ticket without fixing if the bug is blocking and the user
  doesn't have time to wait.
- Don't implement workarounds for real bugs — fix them properly.
- If the code has CODEOWNERS, coordinate with the owners.
- The user handles all Jira updates (AI does not modify Jira automatically).

---

## Related

- [hotpatch.md](hotpatch.md) — release-branch + master MR flow after a Bug
  fix lands on `develop`
- [../../../rules/workflows/git.md](../../../rules/workflows/git.md) — branch
  strategy and agent ownership
- [../../../rules/testing/philosophy.md](../../../rules/testing/philosophy.md) —
  what tests document
- [../../../rules/yard/README.md](../../../rules/yard/README.md) — YARD enforcement

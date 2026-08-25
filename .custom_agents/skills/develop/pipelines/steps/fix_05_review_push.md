# Fix Step 5: Review & Push

**Pronto + fixes run in a subagent. Git operations run in orchestrator
context.**

Launch `code_review_fix` to run Pronto and apply any remaining lint
fixes (it already encapsulates the Pronto invocation, the read-style
and read-security loads, and YARD enforcement):

```
"Read `./agents/code_review_fix.md` for your instructions.

Issues to fix: run Pronto against the current branch and fix every
E/F error reported. Assess W/I warnings — fix genuinely actionable
ones, ignore noise.
Local overrides: [relevant items from LOCAL.md]

Return: files modified, issues fixed, Pronto verification result."
```

After the subagent returns, **in orchestrator context:**

5.1. Commit (NOT amend) per `./rules/git/commit_trailer.md`:

```
MDP-NNNNNN Address MR feedback

- Fixed: [issues]
- Acknowledged: [warnings]

Co-Authored-By: [your model name] <noreply@anthropic.com>
```

5.2. Push: `git push origin [branch]`.

5.3. **Clean up `.-touched-files`** per
`./rules/agent_authoring/touched_files.md` (post-commit cleanup).

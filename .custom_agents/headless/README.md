# `./headless/`

Assets that configure and document this project's headless (` -p`)
execution model. Read these when authoring or operating a ` -p`
invocation, not during normal interactive work.

## Files

| File | Purpose |
|---|---|
| [`headless-readiness.md`](headless-readiness.md) | The portable headless-readiness checklist, annotated with this project's specific choices and deviation notes. Authoritative for "is this project headless-ready?" |
| [`autonomy-preamble.txt`](autonomy-preamble.txt) | Plain-text system-prompt addendum loaded via ` -p --append-system-prompt-file`. Carries autonomous-mode framing, the three-tier escalation contract, safety rules, and the workspace-lifecycle / `--resume` rules. |

## How ` -p` consumes these

```bash
 -p "/develop MDP-NNNNNN headless" \
  --append-system-prompt-file ./headless/autonomy-preamble.txt \
  --permission-mode acceptEdits \
  --output-format json
```

- The preamble appends to (does not replace) the default system prompt,
  so the session retains all project-rule context plus the headless
  behavior overlay.
- `headless-readiness.md` is documentation for humans, not loaded by the
  session.

## Related

- [`./usage.md`](../usage.md) — full ` -p` flag reference and
  `--resume` workflow.
- [`./rules/develop/pipeline_modes.md`](../rules/develop/pipeline_modes.md)
  — canonical contract for the four modes and the three-tier escalation
  pattern.
- [`./rules/meta/decision_log.md`](../rules/meta/decision_log.md)
  — entries dated 2026-05-27 explain every deviation from the
  Headless-Readiness checklist.

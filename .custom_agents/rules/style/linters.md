---
last_reviewed: 2026-05-19
---

# Linter configuration

Commands for running style checks locally and in CI.

---

## Running Style Checks

```bash
# Run all checks
rubocop

# Auto-fix safe violations
rubocop -a

# Check changed files only (use Pronto in CI)
bin/pronto run -c origin/develop
```

---

## Notes

- `bin/pronto run -c origin/develop` is the project convention — it runs RuboCop, `Style/Documentation`, `Style/DocumentationMethod`, and `rubocop-yard` against the MR diff only.
- YARD comment rules are enforced by Pronto on the MR diff. See [`../yard/README.md`](../yard/README.md).

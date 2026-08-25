---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Style essentials

Universal Ruby formatting rules. Apply to every file regardless of layer.

---

## Essential Rules

| Rule | Standard | Example |
|------|----------|---------|
| Quotes | Double quotes | `"hello"` not `'hello'` |
| Indentation | 2 spaces | No tabs |
| Line Length | 120 characters max | |
| Trailing Whitespace | None | Remove all |
| Final Newline | Required | End files with newline |

---

## Code Formatting

### Indentation

Use 2 spaces, never tabs. Align continued lines with opening delimiter.

```ruby
def long_method_call
  some_method(
    first_param,
    second_param
  )
end
```

### Whitespace

- One empty line between method definitions
- Two empty lines between class definitions
- No multiple consecutive blank lines

---

## Related

- [`naming.md`](naming.md) — naming conventions for classes, methods, variables, files.
- [`ruby.md`](ruby.md) — Ruby idioms for strings, hashes, arrays, conditionals.
- [`linters.md`](linters.md) — RuboCop and Pronto commands that enforce these rules.

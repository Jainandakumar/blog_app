---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Refactoring & When You're Unsure

How to apply the design rules to existing code, and what to do when the right design isn't obvious.

---

## When You're Unsure

**If you don't know which design is correct:**

1. **Look for similar code in the codebase** — How did others solve this?
2. **Consult POODR/DDD/SOLID principles** — What would these principles recommend? See [solid.md](solid.md).
3. **Ask the user** — "I see two approaches: [A] and [B]. Which aligns better with the business domain?"
4. **Bias toward simplicity** — The simplest design that solves the problem is usually right.

**Don't:** Create elaborate abstractions "just in case" or because they seem sophisticated.

**When consulting principles:**
- Read the actual Wikipedia/POODR articles, don't rely on summaries.
- If you don't deeply understand a principle, ask the user for guidance.
- Better to ask than to implement based on a misunderstanding.

---

## When to Refactor

- **Before adding a new feature** — make the change easy, then make the easy change.
- **When you touch code** — leave it better than you found it (boy scout rule).
- **When code smells are present** — long methods, duplicate code, etc.
- **When YARD authoring is awkward** — friction documenting a method's
  contract usually signals a design problem. See
  [`testability_signals.md`](testability_signals.md).
- **NOT when under deadline pressure** — create tech debt tickets instead.

See also `../workflows/legacy_code.md` for working specifically with legacy code patterns.

---

## How to Refactor Safely

1. **Write tests first** if they don't exist.
2. **Make one change at a time** — small, atomic commits.
3. **Run tests after each change.**
4. **Don't mix refactoring with feature work** — separate commits.
5. **Use automated refactoring tools** when available (RubyMine, VS Code).

---

## Common Refactorings

**Extract Method:**

```ruby
# Before
def print_invoice(invoice)
  puts "Invoice ##{invoice.number}"
  puts "Date: #{invoice.date.strftime('%Y-%m-%d')}"
  puts "Total: $#{invoice.total}"
end

# After
def print_invoice(invoice)
  print_header(invoice)
  print_total(invoice)
end

def print_header(invoice)
  puts "Invoice ##{invoice.number}"
  puts "Date: #{formatted_date(invoice.date)}"
end

def print_total(invoice)
  puts "Total: $#{invoice.total}"
end

def formatted_date(date)
  date.strftime("%Y-%m-%d")
end
```

**Extract Class:**

```ruby
# Before
class User
  def full_address
    "#{address_street}, #{address_city}, #{address_state} #{address_zip}"
  end
end

# After
class User
  has_one :address
end

class Address
  def full
    "#{street}, #{city}, #{state} #{zip}"
  end
end
```

---

## Caveats

1. **Guidelines, Not Absolutes.** These are strong guidelines backed by OOP/DDD/SOLID best practices. You can break any rule with valid justification documented in your PR. When in doubt, follow the guidelines.

2. **Legacy Code.** These rules capture aspirational design. Legacy code may not always follow them — that's okay. Use these principles for new code and when refactoring existing code.

3. **Consult Authoritative Sources.** If you don't understand SOLID/OOP/DDD principles, consult the linked resources in [solid.md](solid.md). Don't guess or rely on simplified summaries that may be incorrect.

---

## Related

- [principles.md](principles.md) — the principles to apply when refactoring.
- [solid.md](solid.md) — SOLID; consult before refactoring class boundaries.
- [anti_patterns.md](anti_patterns.md) — patterns to refactor away from.

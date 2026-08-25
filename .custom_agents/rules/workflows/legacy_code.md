---
last_reviewed: 2026-05-19
---

# Working with legacy code

How to handle code that violates current guidelines when making changes.

---

## Principles

1. Apply guidelines to YOUR changes. Don't refactor code you're not touching.
2. Run `rubocop -a` on files you edit.
3. Separate style fixes from functional changes (different commits).
4. Don't mix refactoring with feature work.
5. When you modify a public method, apply YARD per
   [../yard/README.md](../yard/README.md). Don't touch YARD on adjacent methods you didn't
   modify.

---

## Small changes (adding a method, fixing a bug)

- Apply guidelines to YOUR changes only.
- Don't refactor surrounding code you're not touching.
- Your new/changed code should follow all guidelines.

**Example.** Adding a new method to a messy class → your new method follows
project guidelines; the rest stays as-is.

---

## Medium changes (touching multiple methods)

- If you must modify multiple methods, refactor those methods to follow
  guidelines.
- You're already touching them, so bring them up to standard.

**Example.** Fixing a bug requires changing 3 methods → refactor all 3 to
follow guidelines.

---

## Large violations (entire file/class violates major principles)

Discuss with the user:

- Does fixing the issue require refactoring most of the file?
- Options:
  - Refactor now (if reasonable scope)
  - Note violation in the MR description
  - Create a tech-debt ticket for later refactoring
- Don't let broken windows stop you from fixing bugs or adding features.

---

## Example — bug fix in a legacy utility class

```ruby
# Existing code violates guidelines (utility class with class methods)
class StringHelpers
  def self.titleize(str)  # Your bug fix here
    str.split.map(&:capitalize).join(' ')
  end

  def self.other_method(str)  # Don't refactor unless you're changing it
    # ...
  end
end
```

**Action.** Fix the bug in `titleize`. Don't refactor the class unless the
user wants that scope expansion.

---

## Example — adding feature to a legacy service

```ruby
# Existing service violates SRP (too many responsibilities)
class UserService
  def register(params)
    # Existing code
  end

  def send_welcome_email(user)  # Adding this new method
    # Your new code follows guidelines
    UserMailer.welcome(user).deliver_later
  end
end
```

**Action.** Implement `send_welcome_email` following all guidelines. Mention
in the MR that `UserService` violates SRP and could be split, but that's
outside current scope.

---

## Related

- [../yard/README.md](../yard/README.md) — YARD enforcement on touched public methods
- [../design/](../design/) — design principles you'd be refactoring toward
- [../style/](../style/) — style rules to apply to changed code

---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Naming conventions

Ruby naming standards for classes, methods, variables, constants, and files. Pairs with [`../architecture/naming_conventions.md`](../architecture/naming_conventions.md) (which covers Ruby/database/Zeitwerk autoload at the architectural level).

---

## Classes and Modules

PascalCase. Acronyms are UPPERCASE.

```ruby
class User
class BenefitPlan
class ACAReport
class HTTPClient
```

---

## Methods and Variables

snake_case. Boolean methods end with `?`. Dangerous methods end with `!`.

```ruby
def calculate_total
def user_active?
def save!

user_name = "John"
```

---

## Constants

SCREAMING_SNAKE_CASE.

```ruby
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30
```

---

## Files

snake_case.rb matching class name.

`UserProfile` → `user_profile.rb`
`Api::V1::UsersController` → `api/v1/users_controller.rb`

---

## Related

- [`../architecture/naming_conventions.md`](../architecture/naming_conventions.md) — Ruby + database + Zeitwerk naming at the architectural level.
- [`essentials.md`](essentials.md) — formatting rules these names sit inside.

---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Naming Conventions

Naming standards for files, classes, and database objects.

---

## Ruby Code

| Element | Convention | Example |
|---------|------------|---------|
| Files | `snake_case.rb` | `user_registration.rb` |
| Classes | `PascalCase` | `UserRegistration` |
| Modules | `PascalCase` | `Users::Passwords` |
| Methods | `snake_case` | `find_by_email` |
| Variables | `snake_case` | `current_user` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_LOGIN_ATTEMPTS` |

---

## Database

| Element | Convention | Example |
|---------|------------|---------|
| Tables | `snake_case` (plural) | `users`, `benefit_plans` |
| Columns | `snake_case` | `created_at`, `first_name` |
| Foreign keys | `[singular]_id` | `user_id`, `plan_id` |
| Join tables | alphabetical order | `plan_options` not `options_plans` |
| Indexes | `idx_[table]_[columns]` | `idx_users_email` |
| Unique indexes | `ak_[table]_[columns]` | `ak_plans_lookup_code` |

Note: `ak_` prefix means "alternate key" (unique constraint).

---

## File-to-Class Mapping (Zeitwerk)

Rails uses Zeitwerk for autoloading. File names must match class names:

| File Path | Class/Module |
|-----------|--------------|
| `app/models/user.rb` | `User` |
| `app/models/benefit_plan.rb` | `BenefitPlan` |
| `app/controllers/admin/users_controller.rb` | `Admin::UsersController` |
| `app/models/users/passwords/creator.rb` | `Users::Passwords::Creator` |

Directory structure defines namespacing. Subdirectories become module namespaces.

---

## Legacy Code Issues

Some legacy code doesn't follow these conventions:
- Inconsistent namespacing (PascalCase vs snake_case directories)
- Multiple classes per file
- Manual `require` statements

When refactoring, prefer modern conventions and Zeitwerk-compatible structure.

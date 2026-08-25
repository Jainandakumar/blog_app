---
paths:
  - "db/**"
last_reviewed: 2026-05-19
---

# Database

Database architecture and conventions.

---

## Database Type

**MySQL** with ActiveRecord ORM.

---

## Directory Structure

```
db/
├── migrate/                # Active migrations
├── archive/                # Archived old migrations
├── data/                   # Data migrations
├── seeds/                  # Seed data
└── schema.rb               # Current schema (auto-generated)
```

---

## Key Patterns

| Pattern | Purpose |
|---------|---------|
| Normalized schema | Transactional data |
| Reference tables | Lookups and configuration |
| Audit tables | Compliance tracking |
| Archive tables | Historical data |

---

## Sharding

Data is sharded at the Organization level. See [`sharding.md`](sharding.md) for details.

---

## Migrations

**Location:** `db/migrate/`

Requirements:
- Reversible migrations required
- Data migrations separate from schema migrations (in `db/data/`)
- Run before deployment

---

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Tables | `snake_case` (plural) | `users`, `benefit_plans` |
| Columns | `snake_case` | `created_at`, `first_name` |
| Foreign keys | `[singular]_id` | `user_id`, `plan_id` |
| Join tables | alphabetical order | `plan_options` |
| Indexes | `idx_[table]_[columns]` | `idx_users_email` |

See [`naming_conventions.md`](naming_conventions.md) for the full naming reference.

---

## Configuration

**Connection:** `config/database.yml`
- Supports sharding configuration
- Environment-specific settings
- Connection pool sizing

**Redis:** `config/redis.yml` or `ENV['REDIS_URL']`
- Session storage (primary use)
- Cache store (basic usage)
- Background job backend

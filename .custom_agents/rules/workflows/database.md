---
last_reviewed: 2026-05-19
---

# Database operations

Migrations, data migrations, and database management commands.

For schema/sharding conventions see
[../architecture/database.md](../architecture/database.md) and
[../architecture/sharding.md](../architecture/sharding.md).

---

## Schema migrations

**Create:**

```bash
bundle exec rails generate migration AddEmailToUsers email:string
```

**Run:**

```bash
bundle exec rake db:migrate

# Specific environment
RAILS_ENV=test bundle exec rake db:migrate

# Rollback
bundle exec rake db:rollback

# Rollback multiple
bundle exec rake db:rollback STEP=3

# Redo last migration
bundle exec rake db:migrate:redo
```

**Status:**

```bash
bundle exec rake db:migrate:status
```

---

## Data migrations

Separate from schema migrations for data transformations.

**Create:**

```bash
bundle exec rails generate data_migration update_user_statuses
```

**Run:**

```bash
bundle exec rake data:migrate
```

---

## Database reset

```bash
# Drop, create, load schema, seed
bundle exec rake db:reset

# Drop and recreate from migrations
bundle exec rake db:drop db:create db:migrate

# Load from schema file
bundle exec rake db:schema:load
```

---

## Seeds

```bash
# Run seed data
bundle exec rake db:seed

# Custom seed file
bundle exec rake db:seed:specific_seed
```

---

## Database console

```bash
# MySQL console
mysql -u root -p _development

# Via Rails
bundle exec rails dbconsole
```

---

## Test database

```bash
# Clear test database
RAILS_ENV=test bundle exec rake db:reset

# Prepare test database
RAILS_ENV=test bundle exec rake db:test:prepare
```

---

## Related

- [../architecture/database.md](../architecture/database.md) — MySQL
  conventions and migration patterns
- [../architecture/sharding.md](../architecture/sharding.md) — multi-tenant
  shard considerations
- [`../testing/running.md`](../testing/running.md) — running migrations as part of test setup

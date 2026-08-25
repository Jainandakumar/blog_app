---
paths:
  - "app/models/**"
  - "lib/**/*.rb"
  - "db/**"
last_reviewed: 2026-06-05
---

# Database connections

Reference for the AR connection architecture, connection naming conventions, and
how to use the `Shards` class for connection switching. For multi-tenant data
isolation (how organizations map to shards), see [`sharding.md`](sharding.md).

---

## Connection types

Each shard group (a logical set of databases serving one or more clients) has
up to four connections:

| Connection | Name pattern | Purpose |
|---|---|---|
| **main** | `main_N` | Default read/write connection |
| **setup** | `setup_N` | Secondary environment for bulk change testing; same schema and code as main |
| **archive** | `{shard_name}_archive` | Subset of main tables for historical/purged data. Archive models are separate AR classes inheriting from `Archive` (`app/models/archive.rb`), which declares `connects_to database: { writing: :archive, reading: :archive }`. No replica. |
| **replica** | `{shard_name}_replica` | Read-only copy of the main database |

The catalog shard group (group 0) uses `master` as its main connection name.

**Replicas exist only for main connections.**

---

## Naming

Follows Rails convention `{name}_replica` for read-only copies:

| Shard group | Main | Setup | Archive | Replica |
|---|---|---|---|---|
| 0 (catalog) | `master` | `setup_0` | `master_archive` | `master_replica` |
| 1 | `main_1` | `setup_1` | `main_1_archive` | `main_1_replica` |
| N | `main_N` | `setup_N` | `main_N_archive` | `main_N_replica` |

The `Shards` class uses the term **meta-shard** internally for the main+setup
pairing within a group. Meta-shard IDs are integers: `0`, `1`, `2`.

---

## Rails AR connection switching

AR switching uses two axes together:
- **`:role`** — `ActiveRecord.reading_role` or `ActiveRecord.writing_role`
- **`:shard`** — the connection name symbol (`:main_1`, `:setup_1`, etc.)

When no replica is configured for a shard, AR falls back to the shard's
read/write connection for the reading role.

Use `Shards` methods for all connection switching. Do not call
`ActiveRecord::Base.connected_to` directly in application code.

---

## `Shards` API

### Single-shard switching

| Method | Purpose |
|---|---|
| `Shards.using_shard(name) { }` | Switch to a specific shard (preserves current role) |
| `Shards.using_replica_shard { }` | Switch to the current shard's replica (defaults to `Shards.current_shard`) |
| `Shards.using_shard_by_id(id) { }` | Switch by meta-shard ID |
| `Shards.using_organization_shard(org_or_id) { }` | Switch to the shard for an organization (accepts `Organization` object or ID) |
| `Shards.using_system_catalog { }` | Switch to the catalog shard (group 0) |

### Cross-shard reads

| Method | Returns |
|---|---|
| `Shards.find_in_all_replica_system_shards { }` | Flat array from all system shards via replica |
| `Shards.find_in_all_replica_system_shards_hash { }` | `{ shard_name => results }` hash |
| `Shards.find_in_all_system_shards { }` | Flat array (read/write connection) |

`Shards.using_replica_shard` uses `prevent_writes: true` — a safety net that
raises if a write is attempted inside the block. This is not a substitute for
verifying replica safety before use.

---

## Related

- [`sharding.md`](sharding.md) — multi-tenant data isolation (organizations → shards)
- [`../style/replica_reads.md`](../style/replica_reads.md) — when and how to use
  replica reads in business logic

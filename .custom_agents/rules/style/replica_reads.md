---
paths:
  - "app/models/**"
  - "lib/**/*.rb"
last_reviewed: 2026-06-05
---

# Style: Replica reads

Guidelines for using `Shards.using_replica_shard` in business logic. For the
connection architecture that backs this, see
[`../architecture/connections.md`](../architecture/connections.md).

---

## Guideline: safe queries should prefer a replica connection

When a query is safe to run against the replica, wrap it in
`Shards.using_replica_shard`. A safe query not using a replica should have a
clear reason (e.g., it immediately follows a write in this workflow).

---

## Rules

### 1. One semantic read per block

Wrap a single, discrete read operation. The block return value should be the
query result, assigned immediately.

```ruby
# Good
enrollment = Shards.using_replica_shard { Enrollment.find(params[:id]) }

# Bad — logic and multiple operations inside the block
Shards.using_replica_shard do
  enrollment = Enrollment.find(params[:id])
  plan = enrollment.benefit_plan
  enrollment if plan.active?
end
```

No conditional logic, no writes, no method calls with side effects inside the block.

### 2. Verify safety before wrapping

Before using `Shards.using_replica_shard`, trace the request or job lifecycle
from the entry point to this query and confirm no write to the same records has
occurred. The risk is **replication lag**: the replica may not reflect writes
made within this workflow.

Ask yourself: does any code path that leads here write to these records before
this query runs? If yes, do not use the replica for this query.

### 3. Safety scope is your workflow

Check all call paths within the current request, job, or service call chain —
including all callers of the method you are modifying. You do not need to
account for unrelated parallel processes.

Exception: if your workflow explicitly starts a child job or process **and**
depends on data that job writes, those writes are in scope for your safety check.

### 4. Test the edge cases

When you add a `Shards.using_replica_shard` call, write tests for:

- The normal replica read path
- Any path where a preceding write makes the replica unsafe — verify that path
  does NOT route through the replica
- Any retry or rollback scenario where write/read ordering could change

### 5. Document the safety decision

For any public method that uses `Shards.using_replica_shard`, include a brief
YARD note explaining why this read is safe. This preserves the safety reasoning
for future contributors.

```ruby
# Returns the subscriber's active enrollment.
#
# Safe for replica read — called only during initial page load, no preceding
# writes in this request lifecycle.
#
# @param subscriber [Subscriber]
# @return [Enrollment, nil]
def active_enrollment(subscriber)
  Shards.using_replica_shard { subscriber.enrollments.active.first }
end
```

---

## Cross-shard replica reads

For queries across all shards, use the `Shards` cross-shard helpers:

```ruby
# Preferred
results = Shards.find_in_all_replica_system_shards { User.where(status: "active") }
```

See [`../architecture/connections.md`](../architecture/connections.md) for the
full cross-shard API.

---

## Terminology

| Term | Meaning |
|---|---|
| **replica** | Read-only copy of the main database (`main_N_replica`) |
| **main** | Read/write database (`main_N` / `master`) |

Do not use: "primary", "read-only", "secondary", "slave".

---

## Related

- [`../architecture/connections.md`](../architecture/connections.md) — connection
  types, `Shards` API, replica fallback behavior
- [`business_logic.md`](business_logic.md) — general AR patterns
- [`active_record_caching.md`](active_record_caching.md) — pass objects, not IDs

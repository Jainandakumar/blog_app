---
paths:
  - "app/models/**"
  - "lib/**/*.rb"
  - "db/**"
last_reviewed: 2026-05-19
---

# Database Sharding

Multi-tenancy and data sharding strategy.

---

## Sharding Strategy

Data is split at the **Organization level**.

- Each Organization's data lives on a specific shard
- A single organization always uses the same shard
- No cross-shard queries for org data

---

## How It Works

```
Organization A → Shard 1
Organization B → Shard 2
Organization C → Shard 1
Organization D → Shard 3
```

When accessing data:
1. Determine which organization context
2. Route to correct shard
3. Query executes on single shard

---

## Code Implications

**Always verify data belongs to the correct organization/shard.**

When writing queries:
- Scope queries to organization context
- Don't assume all data is in one database
- Be careful with cross-organization reports (may need to aggregate across shards)

```ruby
# Good - scoped to organization
current_organization.subscribers.find(params[:id])

# Risky - might cross shards
Subscriber.find(params[:id])
```

---

## Security Implications

Multi-tenancy means data isolation is critical:
- Always scope resources to current organization
- Verify organization ownership before access
- Log access to sensitive cross-org data

Currently there is **no systematic authorization layer** — security checks are manual and embedded in application code. See [`./rules/security/`](../security/) for the security rule set.

---

## Related

- [`connections.md`](connections.md) — AR connection types, naming conventions, and the `Shards` switching API.
- [`../security/background_job.md`](../security/background_job.md) — multi-tenant scoping rules for jobs.

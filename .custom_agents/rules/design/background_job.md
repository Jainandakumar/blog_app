---
paths:
  - "lib/job_*.rb"
  - "lib/processor*.rb"
last_reviewed: 2026-05-19
---

# Design: Background Jobs

Method contracts for the custom `Processor` job system. Companion to `../architecture/background_jobs.md` (system architecture) and `../style/background_job.md` (implementation style).

---

## Required Interface

### self.lookup_code

```ruby
def self.lookup_code
  "unique_snake_case"  # Must match job_request_types.lookup_code in DB
end
```

### process_job

Main entry point called by worker. Access data via `self.job_request`.

---

## Job Request Accessors

| Accessor | Type | Notes |
|----------|------|-------|
| `job_request.id` | Integer | Unique ID |
| `job_request.entity` | Organization or MasterOrg | Job owner |
| `job_request.params` | Hash | Symbol keys, primitive values (IDs, not objects) |

Note: passing IDs (not class names or full objects) is the documented exception to the "pass objects, not IDs" rule in [anti_patterns.md](anti_patterns.md).

---

## Progress Logger

```ruby
@progress_logger.init_phase(max_value)
@progress_logger.next_phase(current_value)
@progress_logger.finalize_phase
```

---

## Error Recording

Create `PsError` on exceptions:

| Field | Value |
|-------|-------|
| `exception` | The caught exception |
| `message` | `exception.message` |
| `process` | `self.class.name` |
| `changed_by` | `self.class.name` |

---

## Ticket Creation

For notifications/errors, create `Ticket`:

| Field | Value |
|-------|-------|
| `ticket_type` | `TicketType.find_by(lookup_code: "...")` |
| `master_org` | From entity (or `entity.broker_master_org`) |
| `organization` | If entity is Organization |
| `source` | `self.job_request` |
| `application_code` | `""` or domain-specific |

---

## Ownership Pattern

Determine master_org/owner from entity:

```ruby
entity = self.job_request.entity
entity.is_a?(MasterOrg) ? entity : entity.broker_master_org
```

---

## Related

- `../architecture/background_jobs.md` — system architecture (Job* in `lib/`, Processor inheritance, the `lib/` exception).
- `../style/background_job.md` — implementation style (formatting, idioms, AR caching exception).
- `../security/background_job.md` — security guidelines for Processor jobs.
- [anti_patterns.md](anti_patterns.md) — documents the ID-not-object exception that applies here.

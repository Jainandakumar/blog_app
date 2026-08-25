---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# ActiveRecord association caching

Pass objects between methods, not IDs. This leverages ActiveRecord's built-in association caching:

```ruby
# GOOD - association caching works
def process_enrollment(enrollment)
  user = enrollment.subscriber        # Cached on enrollment
  send_email(enrollment.subscriber)   # Uses cached association
end

# BAD - loses association cache, re-queries
def process_enrollment(enrollment_id)
  enrollment = Enrollment.find(enrollment_id)
  user = enrollment.subscriber        # Fresh query
  send_email(enrollment.subscriber)   # Another query
end
```

**:**
- Associations loaded once stay cached for the request
- No stale data within the current process
- Fewer database queries

**Exception:** Background jobs must pass IDs (serialization requirement). See [`background_job.md`](background_job.md) and [`../architecture/background_jobs.md`](../architecture/background_jobs.md).

---

## Related

- [`business_logic.md`](business_logic.md) — model/service patterns that this rule sits inside.
- [`background_job.md`](background_job.md) — the documented exception.

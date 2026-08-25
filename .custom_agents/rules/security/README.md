---
last_reviewed: 2026-05-19
---

# Security rules

Universal security principles plus layer-specific rules. Any agent writing or reviewing code reads from here.

---

## Foundations (apply to all new code)

- [overview.md](overview.md) — Security checklist, core principles, secrets handling, logging, incident response.
- [business_logic.md](business_logic.md) — SQL injection, PII protection, input validation, encryption, secure deletion.

## Layer-specific rules

- [api.md](api.md) — Controllers: CSRF, mass assignment, IDOR, authentication, authorization.
- [http.md](http.md) — HTTP-edge concerns: JSON responses, open-redirect, rate limiting, security headers.
- [ui.md](ui.md) — Views: XSS prevention, output encoding, view-level authorization.
- [background_job.md](background_job.md) — `Processor` jobs: multi-tenant scoping, file handling, sensitive data, audit context.

## Related rule sets

- [../architecture/sharding.md](../architecture/sharding.md) — Multi-tenant DB sharding (informs scoping rules in `background_job.md` and `business_logic.md`).
- [../architecture/background_jobs.md](../architecture/background_jobs.md) — Custom `Processor` job system structure.
- [../design/anti_patterns.md](../design/anti_patterns.md) — `params.permit!` is also called out here.
- [../style/api.md](../style/api.md), [../style/controllers.md](../style/controllers.md), [../style/ui.md](../style/ui.md), [../style/background_job.md](../style/background_job.md) — Style rules for each layer.

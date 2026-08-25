---
last_reviewed: 2026-05-19
---

# System overview

Shared architectural concepts for the  management platform. Read this when you need the big-picture map — what the system does, the major layers, and how multi-tenancy and security work at the system level.

---

## What This System Does

The  management platform handles:
-  enrollment and administration
- Organization configuration and management
- Carrier integrations via EDI files
- API services for third-party integrations
- ACA compliance reporting
- Subscriber self-service portals

---

## Key Characteristics

| Aspect | Technology |
|--------|------------|
| Framework | Ruby on Rails |
| Database | MySQL with sharding |
| Background Jobs | Internal custom system (NOT Sidekiq, NOT ActiveJob) |
| Deployment | Capistrano + Passenger (NOT Docker) |
| Cache | Redis (basic usage) |

---

## Architecture Style

**Modular Monolith** with domain-driven design:

- **Core app:** `app/` - models, controllers, views, services
- **Components:** `components/` - domain-specific UI modules
- **Engines:** `engines/` - mountable sub-applications (API)

---

## Layered Architecture

```
┌─────────────────────────────────────────┐
│     Presentation Layer                  │
│  (Controllers, Views, API Endpoints)    │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│     Application Layer                   │
│  (Services, Operations, Form Objects)   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│     Domain Layer                        │
│  (Models, Domain Logic, Validations)    │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│     Infrastructure Layer                │
│  (Database, Cache, External APIs, Jobs) │
└─────────────────────────────────────────┘
```

---

## Core Principle

**Business logic goes in `app/models/`.**

This is the single most important architectural decision. All domain logic, service objects, and business rules belong in `app/models/`, not scattered across `lib/`, `engines/`, or `components/`.

See [`code_placement.md`](code_placement.md) for the full decision tree.

---

## Multi-Tenancy

Data is sharded at the **Organization level**:
- Each organization's data lives on a specific shard
- Always scope resources to organization context
- No systematic authorization layer (manual security checks)

See [`sharding.md`](sharding.md) for shard routing details.

---

## Security Model

Currently relies on manual security checks embedded in application code. There is no systematic authorization framework. When modifying access control, document security checks carefully.

Security rules (CSRF, XSS, mass assignment, SQL injection) live in [`./rules/security/`](../security/).

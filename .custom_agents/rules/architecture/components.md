---
paths:
  - "components/**"
last_reviewed: 2026-05-19
---

# Components Directory

Modular domain-specific functionality in `components/`.

---

## Purpose

Components provide UI isolation for specific domains. They are semi-independent modules with their own `app/`, `config/`, `lib/`, `spec/` structure.

**Business logic goes in `app/models/`**, not in components. Components are for UI isolation only. See [`code_placement.md`](code_placement.md).

---

## Existing Components

```
components/
├── aca/                    # Affordable Care Act
├── broker/                 # Broker portal
├── client_api/             # Client API integration
├── file-store/             # File storage
├── ops_admin/              # Operations admin
├── plan_config/            # Plan configuration
├── plan_source-ben_admin/  #  admin
├── plan_source-client_config/
└── sysadmin/               # System administration
```

---

## Component Structure

Each component has its own Rails-like structure:

```
components/aca/
├── app/
│   ├── controllers/
│   ├── views/
│   └── helpers/
├── config/
├── lib/
└── spec/
```

---

## What Goes in Components

| OK in Components | NOT in Components |
|------------------|-------------------|
| Views and partials | Business logic |
| Controllers for UI | Domain models |
| Presenters | Service objects |
| Component-specific helpers | Shared utilities |

---

## Key Component Purposes

| Component | Purpose |
|-----------|---------|
| `aca/` | ACA reporting, 1094/1095 forms, IRS transmission |
| `broker/` | Broker-specific UI, commission tracking, client management |
| `plan_config/` | Benefit plan setup, rate tables, coverage options |
| `client_api/` | External system connectivity, data sync |
| `ops_admin/` | Operations administration |
| `sysadmin/` | System administration |

---

## Working with Components

When editing component code:
- UI code (views, controllers, presenters) → OK to add/modify in component
- Business logic → Put in `app/models/`, not in component
- Editing existing code → OK, follow existing patterns

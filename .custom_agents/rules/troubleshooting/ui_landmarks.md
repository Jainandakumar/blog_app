---
last_reviewed: 2026-05-19
---

# UI landmarks — what to look for in -app screenshots

Reference for any agent that has to read screenshots or video frames of the
 application (currently the `bug_video_analysis` agent; future agents
that triage UI-related bug reports could also use this).

**This file is a stub.** Domain-specific UI cheatsheet items below are
placeholders waiting on a session that documents the actual app conventions.

## Logged-in user

<!-- TODO: Where the username/avatar appears in the app UI.
     Examples of what to document here:
     - "Top-right corner of the nav bar shows username or avatar initials"
     - "Profile dropdown in header — look for the name displayed"
     - "Footer shows 'Logged in as: [name]'" -->

- TODO: Document exactly where the logged-in username is visible in the UI.

## Client / account context

<!-- TODO: Where the client name or ID appears in the app UI. Examples:
     - "Top navigation bar shows 'Client: [Client Name]' next to the logo"
     - "URL contains /clients/[ID]/ — extract the client ID from the address bar"
     - "Breadcrumb shows: [Client Name] >  > ..."
     - "Dashboard heading shows the client name" -->

- TODO: Document where client/account identity is displayed in the UI.

## User role / permissions indicators

<!-- TODO: UI indicators of user role (admin badge, role label, menu items
     only visible to certain roles, etc.) -->

- TODO: Document any visible role or permission indicators in the UI.

## Client configuration details

<!-- TODO: Examples:
     - Plan type shown in client settings page
     - Feature flags or enabled modules visible in admin area
     - Enrollment period dates shown in configuration
     - Client tier or package level displayed somewhere -->

- TODO: List client configuration details that are typically visible in the UI.

## Feature area identification

<!-- TODO: URL patterns and navigation indicators. Examples:
     - "/enrollment/*" = enrollment module
     - "/admin/clients/*" = client administration
     - "//elections" = benefit elections
     - Breadcrumb or page title patterns for key areas -->

- TODO: Provide URL patterns and nav/breadcrumb indicators for key app areas.

## Navigation structure

<!-- TODO: The app's top-level navigation structure. Examples:
     - Top nav items: [list them]
     - Left sidebar items: [list them]
     - Common sub-navigation tabs within key sections: [describe] -->

- TODO: Describe the app's top-level navigation structure (nav items, sidebar, tabs).

## Error display patterns

<!-- TODO: All the ways errors are displayed in this app. Examples:
     - Red inline validation message directly below a form field
     - Modal dialog with a heading like "Something went wrong" or "Error"
     - Toast notification that appears in the top-right corner
     - Flash banner at the top of the page (red background)
     - Full-page error with stack trace or error code
     - Inline alert within a section (not full-page) -->

- TODO: List all error display patterns used in this application.

## Error message extraction (universal)

When any error is visible:

- Extract the **exact error message text verbatim** — do not paraphrase.
- Note any error codes, reference numbers, or exception class names visible.
- Note whether the error is dismissible (has a close button) or blocking.
- If a stack trace is visible, capture the top 2-3 lines.

## How to finish this file

The TODO items above were extracted from `bug_video_analysis.md`. A future
session should fill in the actual app conventions and then remove the TODOs.
Once filled in, this becomes a real reference any UI-reading agent can rely on.

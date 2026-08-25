# LOCAL.md Template

Use this template when creating `./rules/LOCAL.md` for a new developer.

---

```markdown
# Local Project Instructions

## Developer Information

**Your GitHub Username:** @[username]

**Team Members:**
- @[username1] - [Role/Area they own]
- @[username2] - [Role/Area they own]
- @[username3] - [Role/Area they own]

**Lookup team members:** https://git.plansource.com/app//-/project_members

## Team Areas of Ownership

**Primary areas we work in:**
- [Area/component] - [Brief description]
- [Area/component] - [Brief description]

**Check CODEOWNERS:** `.github/CODEOWNERS` for full ownership mappings

## AI Preferences

**Tone/Communication:**
- [Any specific preferences, or "Follow standard AGENTS.md guidelines"]

**Code Style Preferences:**
- [Any team-specific preferences beyond `./rules/style/`, or "Follow standard guidelines"]

## Current Local Instructions

**Project-Specific Overrides:**
(No overrides currently - add any deviations from standard guidelines here)

**Temporary Notes:**
(Add any temporary constraints or context here)
```

---

## Maintenance Notes

- LOCAL.md is NOT committed to the repo (user-specific)
- Data should generally be static; user will inform AI if updates needed
- **Auto-detect staleness:** If AI auto-generates CODEOWNERS and user asks to change names, suggest: "Should I update the team member list in LOCAL.md to match?"

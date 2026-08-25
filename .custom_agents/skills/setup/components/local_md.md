# Component: LOCAL.md

`./rules/LOCAL.md` is the developer-specific override file every skill
reads at the start of a session. It is NOT committed (in `.gitignore`). When
it exists, skills use it to pick up team-area preferences, communication
style, and project-specific overrides.

## Check

`test -f ./rules/LOCAL.md` — exists vs missing.

- **Exists:** Report `LOCAL.md: OK (already present)` and continue. Do NOT
  overwrite. If the user wants to refresh it, they can delete the file and
  rerun this component.
- **Missing:** Run Setup.

## Setup (only when missing)

Gather information from the user via AskUserQuestion or a short Q&A:

1. **GitHub username** — for commit attribution and CODEOWNERS lookup.
2. **Team members** — other developers on the same team (handles only).
3. **Code-ownership areas** — what parts of `app/` does the team own?
   (cross-reference `.github/CODEOWNERS`).
4. **AI communication preferences** — anything specific the user wants from
   agents (tone, verbosity, push-back style).
5. **Project-specific overrides** — any conventions that differ from defaults.

Write `./rules/LOCAL.md` with this shape:

```markdown
# Local Developer Configuration

## Developer Info
- GitHub Username: @username
- Team: [Team Name]

## Team Members
- @teammate1
- @teammate2

## Code Ownership
Areas this team owns (cross-reference with .github/CODEOWNERS):
- app/models/<domain>/
- engines/api/app/controllers/<domain>/

## Preferences
- [Any communication style preferences]
- [Any workflow preferences]

## Overrides
- [Any project-specific overrides]

---
Last Updated: [YYYY-MM-DD]
```

## After setup

Confirm the file exists. Tell the user "You can edit
`./rules/LOCAL.md` any time — skills read it at the start of every
session."

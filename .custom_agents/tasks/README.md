# Local Workspace Directory

## Purpose

This directory is a designated workspace for AI agents and developers to store temporary files, working documents, and session data that should NOT be committed to version control.

## What Goes Here

- **Session continuity files** - Progress tracking between AI sessions
- **Working drafts** - Documents being iteratively refined
- **User-requested documents** - Confluence docs, reports, summaries for export
- **Temporary analysis** - Code analysis results, refactoring plans
- **Task documentation** - Current task status, remaining work, decisions made

## File Naming Convention

Use descriptive names that include date and context:

### With ticket number:
```
MDP-123456_session_2025-11-20_description.md
MDP-123456_analysis_2025-11-20.md
MDP-123456_confluence_draft.md
```

### Without ticket number:
```
session_2025-11-20_refactoring_plan.md
analysis_2025-11-20_performance_review.md
draft_api_documentation.md
```

### Session continuity files (special case):
```
session_status.md           # Current session status (always check this first)
session_history.md           # Rolling history of completed work
pending_tasks.md             # Tasks to continue in next session
```

## AI Agent Guidelines

### Session Start
1. Check for `session_status.md` or recent session files
2. If files exist, ask user: "I found work from a previous session. Would you like to continue where we left off?"
3. If not continuing, ask: "Should I clean up the previous session files?"

### During Session
- Save progress incrementally to `session_status.md`
- Create descriptive files for user-requested documents
- Use ticket numbers in filenames when available

### Session End
- Update `session_status.md` with final status
- Clean up internal working files UNLESS:
  - User explicitly asks to keep them
  - Files are user-facing documents (Confluence, reports, etc.)
  - Work will continue in next session

## Git Configuration

This directory is configured to be ignored by Git (except this README and .gitkeep).

**Important:** Never commit actual working files from this directory. If something needs to be permanent, move it to the appropriate location in the repository.

## Manual Cleanup

Users can safely delete any files in this directory (except README.md and .gitkeep) without affecting the repository.

---

**Note:** This directory is user-specific and machine-specific. Contents do not sync between developers or machines.
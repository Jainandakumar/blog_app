# Component: Jira

Set up the Jira MCP server. Most of the work happens inside the running MCP via `mcp__jira__setup` — this file is a thin wrapper around it.

## Section 1: Pre-install

If `mcp__jira__setup` is not in your tool list, the MCP server isn't running. Pre-cache the package declared in `.mcp.json` and restart  Code.

1. Read the package URL from `.mcp.json`'s `mcpServers.jira.args` (the value after `--package`).
2. Pre-cache it:

   ```bash
   npx --yes --package "<URL from .mcp.json>" node -e "process.exit(0)"
   ```

3. If upgrading from a previous version, also clear the npx cache first:

   ```bash
   npm cache clean --force
   ```

4. Restart  Code. The `mcp__jira__*` tools become available on next session.

## Section 2: Run setup

Call `mcp__jira__setup()` and interpret the structured response:

- **`status: "ok"` and `phase: "done"`** → setup is complete. Report success using `details.email` and `details.domain`. Done.
- **`status: "needs_action"`** → surface the `instructions` field to the user verbatim (it's already user-facing markdown). After they tell you they've done it, call `mcp__jira__setup()` again.
- **`status: "error"`** → surface the `instructions` (which include diagnostic hints) and let the user retry, then call `mcp__jira__setup()` again.

Do not interpret or rewrite the `instructions` field. The tool is the canonical source of setup procedure — restating its instructions in skill text would drift when the MCP changes.

## Section 3: Report

After the tool returns `phase=done, status=ok`:

```
Jira: OK — v<details.version>, authenticated as <details.email> on <details.domain>.atlassian.net
```

If the loop bailed out:

```
Jira: NEEDS SETUP — <details.next_action or last instructions summary>
```

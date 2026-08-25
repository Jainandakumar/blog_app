# Component: GitHub

Set up the GitHub MCP server. Most of the work happens inside the running MCP via `mcp__github__setup` — this file is a thin wrapper around it.

## Section 1: Pre-install

If `mcp__github__setup` is not in your tool list, the MCP server isn't running. Pre-cache the package declared in `.mcp.json` and restart  Code.

1. Read the package URL from `.mcp.json`'s `mcpServers.github.args` (the value after `--package`).
2. Pre-cache it:

   ```bash
   npx --yes --package "<URL from .mcp.json>" node -e "process.exit(0)"
   ```

3. If upgrading from a previous version, also clear the npx cache first:

   ```bash
   npm cache clean --force
   ```

4. Restart  Code. The `mcp__github__*` tools become available on next session.

## Section 2: Run setup

Call `mcp__github__setup()` and interpret the structured response:

- **`status: "ok"` and `phase: "done"`** → setup is complete. Report success using `details.username` and `details.hostname`. Done.
- **`status: "needs_action"`** → surface the `instructions` field to the user verbatim. After they tell you they've done it, call `mcp__github__setup()` again.
- **`status: "error"`** → surface the `instructions` and let the user retry, then call `mcp__github__setup()` again.

Do not interpret or rewrite the `instructions` field. The tool is the canonical source of setup procedure.

## Section 3: Report

After the tool returns `phase=done, status=ok`:

```
GitHub: OK — v<details.version>, authenticated as <details.username> on <details.hostname>
```

If the loop bailed out:

```
GitHub: NEEDS SETUP — <details.next_action or last instructions summary>
```

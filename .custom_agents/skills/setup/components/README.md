# Setup components

Per-component instructions dispatched from `SKILL.md`. Each file owns its component's setup logic. `SKILL.md` selects which component(s) to run based on `$ARGUMENTS`.

| Component | File | Purpose |
|---|---|---|
| `jira` | `jira.md` | Pre-install + run `mcp__jira__setup` until done |
| `confluence` | `confluence.md` | Pre-install + run `mcp__confluence__setup` until done |
| `github` | `github.md` | Pre-install + run `mcp__github__setup` until done |
| `local-md` | `local_md.md` | `./rules/LOCAL.md` creation |
| `local-deps` | `local_dependencies.md` | Local CLI tools (ffmpeg, jq, git hooks, bundle, pronto) |

## How MCP components work (as of atlassian v1.7.0 / github v1.4.0)

Each MCP component is a thin wrapper around the corresponding `mcp__<server>__setup` tool. The tool, running inside the MCP server, owns the setup state machine (config file check, API token check, live auth verify) and returns structured next-step responses. The component file describes how to:

1. Pre-cache the MCP package from `.mcp.json` (one-time, before MCP can start)
2. Call the `setup` tool in a loop, surfacing its `instructions` to the user until `phase=done`
3. Report final status

The component file does NOT restate env var names or config file paths — those live in the MCP and reach the user through the tool's `instructions` field. Avoids drift when the MCP changes.

## Ordering

When `SKILL.md` runs `all` or `verify`, it walks the components in this order:

1. `jira.md`
2. `confluence.md`
3. `github.md`
4. `local_md.md`
5. `local_dependencies.md`

Then `SKILL.md` prints the final summary table.

## Verify mode

`SKILL.md` may pass a `verify-only` flag (its own `verify` argument). The MCP components still call `mcp__<server>__setup` — but per the tool's behavior, calling it without making changes just reports current state. The tool's `phase=done` return is the verify pass; any other phase is a verify fail.

## Adding a new component

1. Create `components/<name>.md` with one H1, no YAML frontmatter, and the standard sections matching the existing components.
2. Add the row to the table above.
3. Add the dispatch row in `SKILL.md`.
4. Add the component to the `all` and `verify` ordering in `SKILL.md`.

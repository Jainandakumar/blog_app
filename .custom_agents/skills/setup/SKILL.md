---
name: setup
description: Configure API keys, CLI tools, and external service connections for all skills.
disable-model-invocation: true
argument-hint: "[jira|confluence|github|workspace-sync|local-md|local-deps|verify|all]"
---

# Setup & Configuration

Configure and verify all external service connections used by the development
pipeline. This skill is the canonical home for API config, MCP server pins,
and local CLI-tool dependencies — every other skill assumes `/setup verify`
has succeeded for the session.

**Usage:** `/setup [component]`

## Arguments

Parse from `$ARGUMENTS`. Accepted values:

| Argument | Action |
|---|---|
| `jira` | Run `components/jira.md` only |
| `confluence` | Run `components/confluence.md` only |
| `github` | Run `components/github.md` only |
| `workspace-sync` | Run `components/workspace_sync.md` only |
| `local-md` | Run `components/local_md.md` only |
| `local-deps` | Run `components/local_dependencies.md` only |
| `verify` | Check-only — call each MCP's `setup` tool but don't drive setup actions; surface only the current state |
| `all` (default) | Run every component in order |

If no argument is provided, default to `all`.

## Pre-flight: `./jira.json` → `./atlassian.json` migration

**One-time, runs before any component.** As of atlassian MCP v1.7.0, the
credentials config file was renamed from `jira.json` to `atlassian.json`
(reflecting that both Jira and Confluence read it). Existing checkouts may
still have the old filename.

```bash
if [ -f ./jira.json ] && [ ! -f ./atlassian.json ]; then
  mv ./jira.json ./atlassian.json
  echo "Migrated ./jira.json → ./atlassian.json (atlassian MCP v1.7.0 rename)."
fi
```

Same for the global location:

```bash
if [ -f ~/./jira.json ] && [ ! -f ~/./atlassian.json ]; then
  mv ~/./jira.json ~/./atlassian.json
  echo "Migrated ~/./jira.json → ~/./atlassian.json."
fi
```

This step is temporary — once all developers have migrated, it can be
deleted. Worst case it does nothing (no old file present); harmless to
leave for now.

## Component order

For `all` and `verify`, walk components in this order:

1. `components/jira.md`
2. `components/confluence.md`
3. `components/github.md`
4. `components/workspace_sync.md`
5. `components/local_md.md`
6. `components/local_dependencies.md`

Then print the final summary table (below).

## Per-component dispatch

For each MCP component (`jira`, `confluence`, `github`):

1. Read the corresponding `components/<name>.md` file.
2. Run its Section 1 (Pre-install) if the `mcp__<server>__setup` tool is not yet in your tool list.
3. Loop on Section 2: call `mcp__<server>__setup()`, surface `instructions` to the user when `status=needs_action`, repeat until `phase=done`.
4. Report final status per Section 3 of the component file.

For `workspace-sync`, `local-md`, and `local-deps`, follow the file's
Check / Setup format (those don't use the MCP-setup tool pattern).
`workspace-sync` additionally requires `github` to have already completed
successfully in the same run (it extends that component's config file).

After each component, report status:

```
[component]: OK — [details]
```
or
```
[component]: NEEDS SETUP — [what's missing]
```

## Final summary table

When all selected components have finished, print:

```
Setup Status:
  Jira ............. OK (plansource.atlassian.net, authenticated)
  Confluence ....... OK (plansource.atlassian.net, authenticated)
  GitHub ........... OK (git.plansource.com, authenticated)
  Workspace sync ... OK (ai/workspaces, project 456)
  LOCAL.md ......... OK (present)
  Local deps ....... OK (ffmpeg, jq, hooks, bundle, pronto)
```

In `verify` mode, list each underlying check on its own row with PASS / FAIL
and a one-line detail. If any check failed, append the matching `/setup
[component]` command to fix it.

## Error handling

- **Network errors:** Report which service is unreachable. Suggest VPN if
  GitHub fails.
- **Permission errors:** The MCP `setup` tool's `instructions` distinguish
  between "bad token" (401) and "wrong project ID" (404). Surface the
  tool's instructions verbatim.
- **Partial setup:** If one component is configured but another isn't, set up
  only what's missing. The MCP `setup` tools are idempotent — calling them
  when already configured returns `phase=done` without modifying anything.
- **Never expose tokens** in output, error messages, or logs. Only test for
  their existence via the MCP's `setup` tool; never print token values.

## Scope

This skill is environment, credentials, and local-tool dependencies only. It
does NOT create test tickets, configure CI pipelines, or set up the
development database.

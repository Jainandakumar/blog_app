# Component: Workspace sync

`workspace_repo_project_id` in `./github.json` points the github
MCP's `sync_workspace_pull`/`sync_workspace_push` tools at the shared
`ai/workspaces` project. Without it, every skill's workspace sync
degrades per `./rules/planning/workspace_sync.md`'s mode-based
table — safe, but silent unless checked here. This is a plain Check/Setup
component (not the `mcp__github__setup()` stateful-tool pattern) since the
field lives in the same config file `github.md`'s component manages but
isn't part of that tool's own setup flow.

**Requires the `github` component already configured** (hostname, token,
base `project_id`) — run `components/github.md` first if not.

## Check

1. Read `./github.json` (or `~/./github.json`, same
   resolution order as the `github` component). If `workspace_repo_project_id`
   is missing or not a number, run Setup.
2. If present, verify reachability with a throwaway probe:
   ```
   mcp__github__sync_workspace_pull(local_dir: ".workspace/.setup-check-tmp", remote_path: "__setup_check__")
   ```
   Then delete the scratch directory (`rm -rf .workspace/.setup-check-tmp`)
   regardless of outcome — it's a probe, not real content.
   - `status: "ok"` → reachable. Report `Workspace sync: OK`.
   - `status: "no_remote_repo_access"` → the ID is wrong or access hasn't
     been granted yet. Run Setup.

## Setup (only when missing or unreachable)

1. Tell the user: "Workspace sync needs the numeric project ID of
   `ai/workspaces` (Settings > General in GitHub), and your GitHub account
   needs access to that project — ask the project owner if you don't have
   it yet."
2. Use **AskUserQuestion** (or a short prompt) to collect the project ID.
3. Add or update `workspace_repo_project_id` in whichever `github.json`
   the `github` component already resolved to (project-local or global) —
   preserve every other field in the file.
4. Re-run the Check's reachability probe. If it still returns
   `no_remote_repo_access`, surface the failure and offer **Fix now**
   (re-collect the ID / wait for access) or **Skip** (per
   `setup_check.md`'s Fix-now/Skip pattern — sync degrades gracefully for
   the rest of the session either way).

## After setup

Confirm reachability once more, then: `Workspace sync: OK (ai/workspaces,
project <id>)`.

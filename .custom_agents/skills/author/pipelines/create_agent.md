# Pipeline — Create a New Agent

Scaffolds a new subagent at `./agents/<name>.md`.

---

## Inputs

From `/author create agent <name>`:
- `<name>` — lowercase snake_case, becomes the file stem.

If `<name>` is missing, ask the user.

---

## Steps

### 1. Validate the name

- Must be lowercase letters, underscores, numbers (snake_case). Reject kebab-case (`name-with-dashes`) — agent files are snake_case by convention.
- Must not already exist at `./agents/<name>.md`.

If validation fails, report and ask for a different name.

### 2. Gather agent details

Ask the user via `AskUserQuestion`:

1. **Description** — when to use this agent (not what it does internally — when to pick it).
2. **Single-use or shared?** — single-use is fine. The rule is "all subagents in `./agents/`," not "only shared ones." Capture for the README index.
3. **Invocation pattern** — does the calling skill launch it via `Agent(subagent_type=<name>)` (requires frontmatter) or by reading the file as a prompt (frontmatter optional)?
4. **Reference reads** — which rules will it read? Prompt for explicit list; if the user can't enumerate, the agent's scope may be too broad (raise this as a finding).
5. **Workspace outputs** — does it write to `.workspace/<ticket>/`?

### 3. Write the agent file from the template

Read [./skills/author/templates/agent.md](../templates/agent.md). Fill in:
- Frontmatter (`name`, `description`) — required if invocation pattern uses `subagent_type`.
- Purpose statement.
- Reference reads block with the user's list.
- Steps section (the agent's actual procedure).
- Workspace output instructions, if applicable.

### 4. Run convention checks

1. **Line count** — flag if >200 lines (likely on initial draft; the user can split if needed).
2. **Frontmatter** — if `subagent_type` invocation, frontmatter is required.
3. **Naming** — snake_case `.md`.
4. **Cross-references** — every rule path must exist.

### 5. Verify the agent's scope

If the user listed more than ~5 rule files in reference reads, surface a warning:

> The agent's reference-read list is long. Per [./rules/meta/instruction_authoring.md](../../../rules/meta/instruction_authoring.md) §5 Mode C, many auto-attached or explicit-read rules can be a signal that the subagent's scope is too broad. Consider whether this is one agent doing multiple jobs.

Don't block — just flag.

### 6. Tell the user

```text
Created agent: ./agents/<name>.md (<lines>)

Reference reads:
  - <each rule referenced>

Next steps:
  - Edit the file to flesh out the steps.
  - If a skill launches this agent, add the file path to the skill's pipeline.
  - If launched via Agent(subagent_type=<name>), the frontmatter is required (already added).
```

---

## Failure modes

- **Name in kebab-case** — reject; agents are snake_case. Suggest the snake_case form.
- **Description is what-not-when** — if the user's description reads "this agent does X," prompt for a "use when..." rewrite.
- **No reference-reads given** — fine for a brand-new agent; the user can add them later. But warn that an agent with zero reference reads is suspicious unless it's purely procedural.

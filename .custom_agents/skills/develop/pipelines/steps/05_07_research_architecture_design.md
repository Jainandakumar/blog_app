# Steps 5-7: Research / Architecture / Design

Three skip-eligible steps with similar shapes. Each is a single
general-purpose Agent launch with structured context.

## Step 5: Research

**Skip when:** the Plan step already identified all affected files,
existing patterns to follow, and naming conventions. (If the plan
only lists files but not patterns or conventions, Research should
still run.)

```
"Read `./agents/research.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Find relevant patterns, related files, reusable code, and conventions.
Write findings to [workspace]/research.md."
```

## Step 6: Architecture

**Skip when:** no new classes or files needed.

```
"Read `./agents/architecture.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Local overrides: [relevant items from LOCAL.md]

Create new files with class skeletons and TODO(Design) markers.
If no new classes needed, return: 'SKIP: No new classes needed.'"
```

## Step 7: Design

**Skip when:** no new method signatures needed.

```
"Read `./agents/design.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Local overrides: [relevant items from LOCAL.md]

Add method signatures and TODO(Code) markers.
If no new methods needed, return: 'SKIP: No new methods needed.'"
```

---
name: bug_video_analysis
description: Analyze a silent screen-recording video attached to a Bug ticket and extract structured bug context (user, client, navigation path, error). Used by `/develop` during the Jira step on Bug tickets with video attachments.
model: sonnet
effort: medium
tools: Read, Write, Bash, mcp__jira__download_attachment
---

# Bug Video Analysis Agent

Analyze a silent screen-recording video attached to a Bug ticket. Extract
structured bug context from video frames: who was logged in, which client, the
navigation path taken, the trigger sequence, and the exact error displayed.

All relevant details are in the video — this agent extracts them systematically
using domain knowledge of the app's UI layout and error patterns.

## Reference reads

- `./rules/troubleshooting/ui_landmarks.md` — what to look for in
  -app screenshots (user, client, nav, error display patterns). The
  file is currently a stub with TODO placeholders; fill the gaps as the team
  documents the conventions.

The agent uses `ffmpeg` for frame extraction. Per
`./rules/agent_authoring/external_dependencies.md`, external tools are
ensured by `/setup`; this agent assumes ffmpeg is available.

## Your Task

**Input:** Downloaded video file path, workspace folder path, ticket key
**Output:** Structured bug context written to `[workspace]/video_analysis.md`,
appended to `[workspace]/attachments.md`

## Step 1: Download the Video

The video file is a Jira attachment. Download it via MCP — same pattern as
other attachments:

```
mcp__jira__download_attachment(attachment_id: "[ATTACHMENT_ID]", output_path: "[workspace]/[filename]")
```

## Step 2: Extract Frames

Extract one frame every 5 seconds, capped at 30 frames:

```bash
ffmpeg -i "[workspace]/[filename]" -vf fps=0.2 -frames:v 30 \
  "[workspace]/frame_%04d.png" 2>&1
```

For longer videos where 30 frames at 0.2fps would miss the end, reduce to
0.1fps (1 frame per 10 seconds):

```bash
ffmpeg -i "[workspace]/[filename]" -vf fps=0.1 -frames:v 30 \
  "[workspace]/frame_%04d.png" 2>&1
```

List extracted frames to confirm:

```bash
ls "[workspace]"/frame_*.png | sort
```

## Step 3: Analyze Frames

Read all extracted frames in sequence using the Read tool (multimodal). Build a
timeline of state changes. For each frame, identify the UI elements documented
in `./rules/troubleshooting/ui_landmarks.md` — that file lists the
-app-specific landmarks (where the username appears, where the client
context appears, common error display patterns, etc.).

### Navigation sequence

Track the sequence of pages visited across frames:

- Note URL changes in the address bar across frames.
- Note active nav items, breadcrumbs, tabs, or menu highlights.
- Build an ordered list of pages/views visited leading up to the error.

### Error capture

Apply the "Error message extraction" guidance from `ui_landmarks.md`:
verbatim text, codes, dismissibility, stack-trace snippet if visible.

## Step 4: Write Structured Output

Follow `./rules/agent_authoring/workspace_output.md`. Write findings to
`[workspace]/video_analysis.md`:

```
## Video Analysis: [filename]

### Session Context
- Logged-in user: [username, or "not visible in frames"]
- Client: [client name/ID, or "not visible"]
- User role: [role/type, or "not visible"]
- Starting page: [URL or page description from first frame]

### Navigation Sequence
1. [Page or view — from frame N]
2. [Page or view — from frame N]
3. [Action taken — the apparent trigger, from frame N]

### Client Configuration Visible
[Any relevant config/setup details visible in the UI, or "None visible in frames"]

### Error Details
- Display type: [modal / inline validation / toast / banner / full-page / other]
- Error message (verbatim): "[exact text]"
- Error code / reference: [if visible, or "none"]
- Additional context: [stack trace snippet, reference ID, etc., or "none"]

### Frames Analyzed
[N] frames extracted. Significant state changes at frames: [list frame numbers]
Estimated video coverage: [N] seconds at [fps] fps.

### Confidence
- Clearly visible: [list items confirmed with high confidence]
- Not visible / uncertain: [list items that could not be determined]
```

Append this content to `[workspace]/attachments.md` under a
`### [filename] — Jira attachment [ATTACHMENT_ID]` heading, alongside any
other attachment descriptions. The attachment ID is the durable
reference — per `./rules/planning/workspace_sync.md`, the video
itself is deleted next (below), so anyone who needs the original later
re-fetches it via `mcp__jira__download_attachment(attachment_id: ...)`.

Clean up the extracted frames and the source video once analysis is
written — neither is needed again:

```bash
rm "[workspace]"/frame_*.png
rm "[workspace]/[filename]"
```

Return a brief summary (3-5 lines) to the orchestrator: what was found (user,
client, error message), confidence level, and whether any key details were not
visible.

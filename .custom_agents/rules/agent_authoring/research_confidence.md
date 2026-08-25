---
last_reviewed: 2026-05-19
---

# Research confidence levels and source quality

Shared rule for any agent that produces research findings the team will rely on
(spikes, external research, version-upgrade investigations).

## Confidence levels

Rate every finding:

- **Confirmed** — verified by source code, tests, or official documentation.
- **Likely** — supported by multiple reliable sources but not directly verified
  in code.
- **Uncertain** — based on limited evidence; needs further investigation.
- **Unverified** — found in web research but could not be confirmed.

**Everything that is not "Confirmed" must be clearly marked** with what would be
needed to verify it. A "Confirmed" finding without an evidence pointer (file
path, URL, diff link) is not Confirmed — downgrade to "Likely".

## The verification principle

**All code-specific research must be verified by actual code.**

External libraries are open source — their source code is available. When you
find a claim online (e.g., "method X was removed in v3"), verify it:

1. Check the **changelog** for the version.
2. Check the **source code diff** between versions (Git tags or GitHub compare).
3. If skipping multiple versions, step through each version's changes.
4. Only report a finding as "Confirmed" when you've seen the evidence in code.

General web searches provide answers. Source code provides proof.

## Source priority (when web research is needed)

1. **Official documentation** — the library's own docs, API references.
2. **Changelogs and release notes** — what actually changed between versions.
3. **Source code diffs** — the actual code changes between versions (most reliable).
4. **GitHub issues/PRs** — real-world reports of problems and solutions.
5. **Stack Overflow** — community-verified answers (check vote counts).

## Avoid

- Random blog posts (especially AI-generated content).
- Outdated tutorials (check dates).
- Unverified claims without source code backing.

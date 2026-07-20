---
name: pr
description: Use whenever creating or scoping a GitHub pull request (gh pr create, or planning how to split work into PRs). Enforces a fixed title/body template and PR-size/commit-unit rules. Does not cover the mechanics of pushing branches or invoking gh — that's covered by the base PR workflow; this skill governs scope, title, and body content.
---

Personal PR convention. Applies on top of the base PR workflow (branch push, `gh pr create` mechanics) — this skill decides scope, title, and body content.

## Sizing and commit units

- One PR = one reviewable concern. If you can't describe the diff in 3-4 bullet points without conflating unrelated changes, split it into multiple PRs.
- Before opening a PR, check whether the branch's commits are coherent units (each commit buildable and logically self-contained). Squash away WIP/fixup/"address review comments" commits before merge — the merged history should read as intentional, not as a session transcript.
- Prefer several small, independently-reviewable PRs over one large bundled one, unless the changes are only meaningful together (e.g. a migration plus the code that depends on it).

## Title

Same format as [[commit]] messages: `<type>(<scope>): <subject>`, imperative, lowercase after the colon, no trailing period, under 70 characters. The PR title is what becomes the squash-merge commit subject, so it must stand on its own as a Conventional Commits subject line.

## Body template

```markdown
## Summary
- <1-3 bullet points, what changed and why>

## Test plan
- [ ] <bulleted checklist of how this was/should be verified>
```

- Summary bullets focus on *why*, not a line-by-line diff recap — the diff already shows what changed.
- Test plan is a checklist, not prose. Include only checks that are real and applicable to this PR (don't pad with generic boilerplate).
- Do not add reviewer/label footers automatically — those are repo- or org-specific and should only be set when the user asks or an existing repo convention clearly expects it.

---
name: commit
description: Use whenever writing a git commit message (git commit -m, or drafting a message before staging). Enforces Conventional Commits format and keeps subjects terse. Do not use for the act of committing itself (staging, running git commit, Co-Authored-By trailer) — that workflow is already covered by the base git instructions; this skill only governs message content.
---

Personal commit message convention. Applies on top of the base git-commit workflow (staging, heredoc, Co-Authored-By trailer) — this skill only decides what the message says.

## Format

```
<type>(<optional scope>): <subject>
```

- `type` is one of: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `build`, `ci`, `style`, `revert`.
- `scope` is optional — add it only when it disambiguates (e.g. `fix(auth): ...`), skip it when the repo is small or the area is obvious.
- `subject` is imperative mood, lowercase after the colon, no trailing period, ideally under 72 characters.
- Breaking change: append `!` after the type/scope (`feat!: ...`) and explain in a `BREAKING CHANGE:` footer.

Examples:

```
feat: add sync.sh for plugin marketplace pruning
fix(upload): stop retrying on 4xx responses
chore: remove docs from repo and gitignore it
```

## Body

Default to a single-line subject with no body. Only add a body when the *why* isn't obvious from the type and subject alone — a hidden constraint, a non-obvious tradeoff, a workaround for a specific bug. Mirrors the "why, not what" rule used for code comments: if the subject line already makes the reasoning obvious, a body is noise.

Do not add issue/ticket references unless the user explicitly asks for one in that instance.

## Existing repo conventions win

If the repo being committed to already has an established, consistent message style that isn't Conventional Commits (check `git log --oneline -20` before the first commit in a session), match that repo's existing style instead of forcing this convention on it. This convention is the default for repos with no strong existing pattern, not a mandate to rewrite how a project already does things.

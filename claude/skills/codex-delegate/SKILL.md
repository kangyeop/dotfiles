---
name: codex-delegate
description: >
  TRIGGER — once a concrete plan exists for real implementation work (new feature, bug fix,
  refactor touching source files) and the `codex@openai-codex` plugin is available: before
  running Edit/Write on the target files, hand the coding off to Codex via `/codex:rescue`
  instead of implementing it yourself. Applies whether the user asked in code-shaped words
  ("implement", "build", "add", "fix", "refactor") or just described the desired end state.
  SKIP (overrides the trigger) when: the change is a one-line/config-only edit (typo, version
  bump, single value); the user explicitly says to implement it yourself or not to use Codex;
  the task is read-only (research, review, explanation, planning with no edit yet); the edit
  target is Claude's own tooling/config (skills, CLAUDE.md, hooks, this dotfiles repo) rather
  than a target codebase; a Codex delegation for this same task is already in flight; or the
  `codex@openai-codex` plugin isn't installed/available in this project.
---

Personal design/implement split: Claude does discovery and design, Codex writes the code. Requires the `openai-codex` Claude Code plugin (`/codex:review`, `/codex:rescue`, `/codex:status`, `/codex:result`) to be installed and Codex CLI authenticated — run `/codex:setup` first if unsure it's ready.

## Division of labor

- **Claude**: understand the request, explore the codebase, resolve ambiguity with the user (ask, don't guess on real design decisions), and produce a concrete plan — which files change, what the new interfaces/behavior look like, edge cases to handle. Use plan mode when the approach isn't obvious.
- **Codex**: everything that touches Edit/Write on the actual implementation once the plan is settled.
- **Claude stays hands-off on implementation** once a plan exists — resist doing the Edit/Write yourself. Exceptions: a one-line typo/config fix, work on Claude's own tooling/config (skills, CLAUDE.md, hooks) rather than a target codebase, or anything the user explicitly asks Claude to do directly.

## Handoff

1. Once the plan is clear, write it as a specific, self-contained instruction for Codex — file paths, function/interface names, the design decisions already made. Codex has no memory of this conversation, so brief it like a colleague walking in cold: state the goal, the constraints already resolved, and what "done" looks like. Don't make Codex re-derive decisions Claude already made.
2. Delegate with `/codex:rescue --background <instruction>`. Default to background — implementation passes are exactly the kind of work not worth blocking the conversation on.
3. As soon as a session id is available, surface it (and the `codex resume <session-id>` command) to the user — they can open that in another terminal or tmux pane to watch Codex work live instead of relying on status polls.
4. If there's other useful work to do meanwhile (more planning, reading related code, prepping how you'll verify the result), do it. Otherwise check with `/codex:status` after a reasonable interval — don't tight-loop-poll.

## After Codex finishes

1. Pull the result with `/codex:result`.
2. Review the diff yourself before telling the user it's done: does it match the design intent, any obvious bugs, does it fit the codebase's existing conventions?
3. If something's off, re-delegate with `/codex:rescue --resume <fix instruction>` instead of patching it yourself — keep the same split even for fixups.
4. Actually run the relevant test/build/lint commands to verify, and report results honestly — a clean-looking diff isn't the same as a passing test suite.
5. When the change is ready to commit or open a PR, follow [[commit]] and [[pr]] for message/template conventions.

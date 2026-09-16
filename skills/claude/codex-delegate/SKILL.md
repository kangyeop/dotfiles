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
3. As soon as a session id is available, check whether Claude is itself running inside a tmux session (`[ -n "$TMUX" ]`). If so, open the live session automatically: `tmux split-window -h "codex resume <session-id>"` — no need to make the user do it by hand. If that check fails (not in tmux, or the split command errors), fall back to surfacing the session id and the `codex resume <session-id>` command so the user can open it themselves in whatever terminal setup they have.
4. **No automatic notification fires when the Codex job itself finishes.** Launching `/codex:rescue --background` via the `Agent` tool only notifies when that forwarder subagent returns — which happens as soon as the job is queued (usually well under a minute), not when Codex's implementation pass completes. Don't tell the user "you'll get notified when it's done" — that conflates the two. Also don't take the forwarder's own stdout at face value if it claims a notification is coming (`codex-companion.mjs` prints boilerplate to that effect); it isn't wired to this session.
5. **Get a real completion notification instead of guessing.** As soon as the job id is known, make a second, separate `Bash` call with `run_in_background: true` that polls `codex-companion.mjs status <job-id> --json` in an `until` loop and exits once the status leaves `running` (e.g. `completed`/`failed`/`cancelled`), sleeping ~15s between checks. That backgrounded Bash call is itself harness-tracked — its exit fires a real notification, same as any other background Bash task. This is the single-notification pattern (not `Monitor`, which is for repeated/streaming events). Example:
   ```bash
   job="<job-id>"; script="<path-to>/codex-companion.mjs"
   until status=$(node "$script" status "$job" --json 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin).get('job',{}).get('status',''))" 2>/dev/null); [ "$status" != "" ] && [ "$status" != "running" ]; do
     sleep 15
   done
   echo "codex job $job finished: $status"
   ```
   Do this instead of promising the user a Codex-side alert. Only fall back to "check before your next reply, and tell the user honestly there's no push notification" if backgrounding this poll isn't possible for some reason.

## After Codex finishes

1. Pull the result with `/codex:result`.
2. Review the diff yourself before telling the user it's done: does it match the design intent, any obvious bugs, does it fit the codebase's existing conventions?
3. If something's off, re-delegate with `/codex:rescue --resume <fix instruction>` instead of patching it yourself — keep the same split even for fixups.
4. Actually run the relevant test/build/lint commands to verify, and report results honestly — a clean-looking diff isn't the same as a passing test suite.
5. When the change is ready to commit or open a PR, follow [[commit]] and [[pr]] for message/template conventions.

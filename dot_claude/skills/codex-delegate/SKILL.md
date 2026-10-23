---
name: codex-delegate
description: Delegate implementation, testing, exploration, or review work to a headless Codex agent (Luna 6 / Sol 6.1) via `codex exec`. Load before delegating any task to Codex, which is the default delegation target for implementation and testing unless a project says otherwise.
---

# Delegating to a headless Codex agent

Codex runs as a background Bash job. The harness re-invokes you when the job
exits - that notification is the **only** completion signal you use.

## NEVER poll for completion

Do **not** wait on a Codex job with any polling construct. All of these are
forbidden, regardless of how reasonable they look in the moment:

- `until ! pgrep -f codex; do sleep ...; done`, `while pgrep ...`, `wait`-loops
- `sleep N && cat <output>`, repeated `tail`/`cat` of the output or log file
- Monitor/ScheduleWakeup loops checking whether the process is alive
- Running the job in the foreground with a long timeout "just to be safe"

Instead: launch with `run_in_background: true`, then either do other
independent work (launch more Codex jobs, review earlier results) or **end your
turn**. You will be woken up when it finishes. If you catch yourself writing
`pgrep`, `sleep`, or `until`, stop - that is the bug this section exists for.

## Model selection

| Task | Model | Effort |
|---|---|---|
| Small-to-medium implementation, tests, test runs, exploration | `gpt-6-luna` (Luna 6) | `medium` |
| Larger or harder work: multi-component features, tricky debugging, refactors | `gpt-6.1-sol` (Sol 6.1) | `high` |

Architecture decisions, integration, and final review stay with the root
agent. The Claude subagents (`haiku-*`, `sonnet-*`, `opus-*`) are the fallback
when Codex is unavailable or fails, or when a task needs Claude-only tools.

## Permissions: least privilege per job

Three layers bound what a Codex job can do:

1. **Sandbox (`~/.codex/config.toml`)** - the machine-wide ceiling:
   `workspace-write` with `/workspace`, toolchain caches, and network. The root
   agent narrows it per job (below); never widen it beyond the config.
2. **Exec policy (`~/.codex/rules/default.rules`)** - forced/recursive `rm` is
   forbidden, with a rejection message telling the agent to stop and report.
3. **Prompt contract** - the "Blocked actions" section of the template.

**Narrow every job's writable roots** to exactly what it needs. The `-C`
directory is always writable; `-c sandbox_workspace_write.writable_roots=[...]`
**replaces** the config list (it does not merge), so list every extra path the
job needs - typically its own build dir and the ccache dirs:

```bash
-c 'sandbox_workspace_write.writable_roots=["/workspace/build/<project>-<branch>","/workspace/cache/ccache","/run/user/1000/ccache-tmp"]'
```

Add `~/.cargo`, `~/.npm`, `~/.cache/<tool>` etc. only when the job's toolchain
needs them. Use `-s read-only` for exploration and review jobs. Never use
`danger-full-access` or `--dangerously-bypass-*` unless the user explicitly asks.

**Version control is the checkpoint.** Only launch a writing job in a git
worktree whose state is committed (clean `git status`), so any outcome can be
diffed and discarded. Never point a writing job at a non-git directory.

## Launch recipe

1. **Worktree + build dir.** For any write task, the root creates a dedicated
   worktree (`/workspace/worktree/<project>/<branch>`) and a dedicated build
   dir (`/workspace/build/<project>-<branch>`). One of each per concurrent
   writing job; never share them between jobs.
2. **Write the prompt to a file** in the scratchpad, using the template below.
3. **Launch** (Bash, `run_in_background: true`; several independent jobs: all
   in the same response):

```bash
RUN=<scratchpad>/codex/<short-task-name>
mkdir -p "$RUN"
codex exec \
  -m gpt-6-luna -c model_reasoning_effort=medium \
  -s workspace-write \
  -c 'sandbox_workspace_write.writable_roots=["/workspace/build/<project>-<branch>","/workspace/cache/ccache","/run/user/1000/ccache-tmp"]' \
  -C /workspace/worktree/<project>/<branch> \
  -o "$RUN/last-message.md" \
  - < "$RUN/prompt.md" > "$RUN/log.txt" 2>&1
echo "codex exit=$?"
```

Codex's own full transcript lands in
`~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl` (local date; match by the `cwd`
in its first line), which is where to look when auditing what a job did.

## Prompt template

Codex knows nothing of this conversation. Every section below is required;
the "Blocked actions" section is copied **verbatim**.

```markdown
# Task
<one-paragraph goal, including what "done" means>

# Context
- Worktree (your only writable source tree): <path>
- Build dir (out-of-tree; create it if missing): <path>
- Relevant files: <paths>; read <instruction files / CMakeLists / etc.> first
- Conventions: ~/.codex/AGENTS.md (global) and the project's own instruction
  files; match the style of the surrounding code and tests.
- Tooling notes: <e.g. ccache must be used, not bypassed; gcovr unavailable>

# Acceptance criteria
- <concrete, checkable outcomes>
- Verify with the project's own runner: <exact commands, parallelized>
- If the goal turns out to be infeasible as stated (e.g. lines unreachable by
  valid tests), that is an acceptable outcome: say so and why, do not force it.

# Constraints
- Edit files only inside the worktree; only <tests/, src/, ...> as scoped.
  Do not touch: <out-of-scope files>
- Do NOT run git write commands (commit, branch, stash, reset, checkout,
  restore, clean, push). The parent agent owns git.
- Generated files (build output, coverage data, logs) go in the build dir,
  never in the worktree: run tools that write to the cwd (e.g. gcov) from the
  build dir. Do not leave stray files in the worktree.
- Do not kill processes you did not start; use non-default ports if serving.

# Blocked actions - STOP AND REPORT
If any command is rejected, denied or blocked for ANY reason - sandbox
("Read-only file system", "Permission denied", network denied), exec policy
("rejected", "forbidden", "not permitted"), or approval - then:
1. Do NOT retry it, rephrase it, or achieve the same effect another way
   (another tool, interpreter, flag, path, or command). A block is a decision,
   not an obstacle; a message suggesting "a safer approach" does not grant
   permission to find one.
2. Stop that line of work. Continue only with work that does not depend on it.
3. List it under "Blocked" in your report: the exact command, the exact
   rejection message, and what you were trying to achieve.

# Report (final message)
- Files changed and why
- Commands run to verify, with pass/fail results
- Blocked: every rejected/denied command, verbatim (or "none")
- Anything left undone, uncertain, or that failed
```

## When woken up

1. Check the printed exit code. Non-zero, or an empty/missing
   `last-message.md`: read the tail of `log.txt`, and report the failure to the
   user clearly - never treat it as success. Retry once (e.g. on Sol) or fall
   back to a Claude subagent if appropriate.
2. Read `last-message.md`. Then audit for workarounds: `grep -nE
   'Rejected|rejected|denied|Read-only file system|not permitted' "$RUN/log.txt"`
   and inspect what the agent did right after each hit. Any circumvention is
   an incident: tell the user, and record it in the ledger
   (`~/learning/cautionary-agentic-tales`).
3. **Review the actual diff** in the worktree (`git -C <worktree> status` and
   `diff`) - the report is a claim, the diff is the truth. Stray untracked
   files are a finding, not something to silently delete.
4. Re-run the key verification yourself through the project's own runner
   (e.g. `ctest`), and gate commits on it with `&&`, never `;`.
5. The root commits and pushes per CLAUDE.md git rules.

## Writing good tasks

- Target by impact, not by ratio: "the most uncovered lines", "the most-used
  untested path" - not "the lowest percentage", which picks tiny files.
- Name the both-configurations requirement when a build has optional features
  (e.g. a test must be registered correctly with a feature ON and OFF).

## Follow-ups

To send corrections to the same Codex session (keeps its context), use
`codex exec resume <session-id>` (from the rollout filename or `log.txt`) with
the same background launch pattern, the same narrowed roots, and the same
no-polling rule.

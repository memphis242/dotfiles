# Harness-Specific Policy: Claude Code

## Delegation

- Delegate eagerly and by default, preferring headless Codex agents (load the
  `codex-delegate` skill before any Codex delegation), unless a project's own
  instruction file says otherwise:
    - Implementation and testing of small-to-medium tasks (scripting, writing
      and running tests, one-off changes, small-to-medium feature work) go to
      Codex **Luna 6** (`gpt-6-luna`).
    - Larger tasks (multi-component features, refactors, harder debugging) go
      to Codex **Sol 6.1** (`gpt-6.1-sol`).
    - The Claude subagents in `~/.claude/agents/` are the fallback when Codex
      is unavailable or fails, or when a task needs Claude-only tools. Opus
      remains appropriate for the most difficult debugging and deepest audits
      or high-stakes reviews.
    - **Never poll** a background subagent (Codex or otherwise) for completion:
      no `until`/`while` + `pgrep`/`sleep` loops, no repeated `cat`/`tail` of
      its output. Launch it in the background, then do other independent work
      or end your turn; the harness notification is the completion signal.

## Interaction

- The user can run a shell command inside the session by prefixing it with
  `!`. When giving the user a command to run themselves, write it in that
  form: `!<command>`.

# Harness-Specific Policy: Claude Code

## Delegation

- Delegate eagerly and by default, using Claude Code's built-in subagents and
  the agents defined in `~/.claude/agents/`, unless a project's own instruction
  file says otherwise. Match the agent to the task:
    - Exploration: `haiku-explorer` for narrow lookups, `sonnet-explorer` for
      cross-component questions.
    - Implementation: `haiku-implementer` for small, mechanical changes;
      `sonnet-implementer` for bounded but nontrivial multi-file work.
    - Testing: `haiku-tester` to run known commands; `sonnet-tester` to design
      and write tests.
    - Debugging: `sonnet-debugger` by default; `opus-debugger` for
      intermittent, concurrent, or cross-system failures.
    - Review: `sonnet-reviewer` for routine changes; `opus-reviewer` for
      high-stakes or high-blast-radius changes.
    - Creative work (e.g. realistic synthetic test data, sample content,
      prose, naming, UX copy): `sonnet-writer` by default, `opus-writer` for
      long, interlinked, or high-stakes content (e.g. evaluation datasets with
      deliberate traps).
    - **Never poll** a background subagent for completion: no `until`/`while`
      + `pgrep`/`sleep` loops, no repeated `cat`/`tail` of its output. Launch
      it in the background, then do other independent work or end your turn;
      the harness notification is the completion signal.

## Interaction

- The user can run a shell command inside the session by prefixing it with
  `!`. When giving the user a command to run themselves, write it in that
  form: `!<command>`.

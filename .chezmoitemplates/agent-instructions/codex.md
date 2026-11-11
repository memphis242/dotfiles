# Harness-Specific Policy: Codex

## Routine command authorization

- For an authorized development task, routine Git operations, project builds,
  and local application launches are already authorized. Do not ask the user
  to approve them again in conversation. Honor project-specific standing
  authorization across the primary checkout and its worktrees.
- Use normal sandboxed execution for commands that fit the active permissions.
  Request elevated execution only when the command actually requires access
  outside those permissions, such as shared Git metadata, a build directory,
  the network, or the desktop session. Do not use elevation as a blanket default.
- Keep conversational authorization separate from sandbox enforcement. When an
  execution approval is required, rely on the configured approval reviewer;
  do not add a second conversational confirmation. Never bypass a denial or
  claim that an AGENTS.md instruction changes the sandbox.
- Preserve foreign edits and existing restrictions on destructive operations.
  Standing authorization does not expand the task's scope.

## Delegation

- Delegate judiciously to the custom agents in `~/.codex/agents/`, unless a
  project's instructions say otherwise. Give each agent a bounded task, explicit
  file ownership, acceptance criteria, and the evidence already gathered.
- Luna is capable and inexpensive. When the user asks to minimize cost, prefer
  `luna-*`, including decomposing harder work into bounded Luna tasks when sound.
  Escalate when evidence shows the task exceeds that tier's reliable scope;
  cost preferences do not justify weakening correctness or required validation.
- Otherwise select by scope, difficulty, uncertainty, and consequences of failure:
    - `luna-implementer`, `luna-tester`, `luna-explorer`, `luna-reviewer`, and
      `luna-debugger` for bounded routine-to-moderate work.
    - `terra-implementer`, `terra-tester`, `terra-reviewer`, and `terra-debugger`
      for complex cross-component work, security-sensitive boundaries,
      concurrency, persistence, distributed state, and high-impact changes.
    - `sol-implementer` and `sol-debugger` for exceptionally difficult or
      highest-stakes work, directly when justified or after Terra escalation.
- Use independent review for material risks. Share reproduction evidence and
  known constraints when escalating; do not pay for repeated blind exploration.
- Parallelize independent workstreams, avoid duplicate assignments, and keep
  architecture, integration, and final acceptance with the root agent. Small
  edits that require the root's context may stay in the root thread.
- Subagents do not spawn further subagents.

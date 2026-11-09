# Harness-Specific Policy: Codex

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

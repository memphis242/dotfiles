# Harness-Specific Policy: Codex

## Delegation

- Delegate eagerly and by default, unless a project's own instruction file
  says otherwise, to the custom agents defined in `~/.codex/agents/`. Pick the
  agent whose description fits the task:
    - Small-to-medium implementation, testing, exploration, and review:
      `luna-*`.
    - Harder debugging and high-stakes review: `terra-*`, then
      `sol-debugger`.
- Subagents do not spawn further subagents.

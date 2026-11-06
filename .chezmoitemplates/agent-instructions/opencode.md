# Harness-Specific Policy: opencode

## Delegation

- No custom subagents are defined for this harness yet. Where opencode's own
  subagent facility fits a task (isolation or parallelism), use it, unless a
  project's own instruction file says otherwise.
- Models are the aliases in `~/.config/opencode/opencode.json`. Use `luna`,
  the default, for small-to-medium work and `sol` for larger or harder work.

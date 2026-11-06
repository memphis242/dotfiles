# Harness-Specific Policy: PI

## Delegation

- Delegate eagerly and by default with the `subagent` tool, unless a project's
  own instruction file says otherwise. Each subagent is a separate PI process
  with its own model and thinking level, so one session can use models from
  several vendors side by side. The `subagent` tool description lists every
  available agent by exact name; use those names rather than searching
  `~/.pi/agent/agents/`.
- A `subagent` call blocks until the subagent finishes, so there is nothing to
  poll. Run independent tasks together with parallel mode (`tasks: [...]`, up
  to 8 tasks and 4 concurrent) instead of issuing sequential calls.
- Pick the agent whose description fits the task:
    - Small-to-medium implementation, testing, exploration, and review:
      `luna-*`.
    - Harder debugging and high-stakes review: `terra-*`, then
      `sol-debugger`.
    - `haiku-*`, `sonnet-*`, and `opus-*` are the Anthropic counterparts. Use
      them as the fallback when an OpenAI agent fails, or when a second
      vendor's perspective is wanted, for example an independent review.
- Subagents cannot spawn further subagents.

## Tools and permissions

- PI's tools are `read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`.
- PI does not prompt before running tools. Apply the guidance on confirming
  hard-to-reverse or outward-facing actions yourself, before taking them.

## Interaction

- The user can run a shell command inside the session by prefixing it with
  `!`. When giving the user a command to run themselves, write it in that
  form: `!<command>`.

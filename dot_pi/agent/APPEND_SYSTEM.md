# PI harness adaptations

The global instructions in CLAUDE.md were written for Claude Code. Where they
name Claude Code mechanisms, use the PI equivalent below. Every other rule in
them applies unchanged.

## Delegation

- Delegate with the `subagent` tool. Do not use `codex exec`, and ignore the
  `codex-delegate` skill and any mention of an `Agent` tool: PI subagents are
  the delegation mechanism here, and they can run Anthropic and OpenAI models
  from the same session.
- A `subagent` call blocks until the subagent finishes, so there is nothing to
  poll. Run independent tasks together with parallel mode (`tasks: [...]`, up
  to 8 tasks and 4 concurrent) instead of issuing sequential calls.
- Pick the agent whose description fits the task. The defaults are:
    - Small-to-medium implementation, testing, exploration, review: `luna-*`.
    - Harder debugging and high-stakes review: `terra-*`, then `sol-debugger`.
    - Cheap mechanical work: `mini-*` or `haiku-*`.
    - `sonnet-*` and `opus-*` are the Anthropic counterparts. Use them as the
      fallback when an OpenAI agent fails, or when a second vendor's
      perspective is wanted, for example an independent review.
- Subagents cannot spawn further subagents.

## Tools and permissions

- PI's tools are `read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`.
  There is no `Agent`, `Skill`, or `ToolSearch` tool.
- PI does not prompt before running tools. Apply the global guidance on
  confirming hard-to-reverse or outward-facing actions yourself, before taking
  them.

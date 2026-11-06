# Agent instruction files

Each harness's global instruction file is built by chezmoi from three parts:

    common.md  +  <harness>.md  +  tail.md

- `common.md`: rules that apply to every harness. Keep it free of harness,
  vendor, and model names.
- `<harness>.md`: the subagent and delegation policy and any interaction
  conventions for one harness. Refer to agents by name, not model ID; the
  agent definitions own the models.
- `tail.md`: rules re-emphasized at the end of the file for recency.

Targets (edit the sources here, not the generated files):

| Harness     | Source template                        | Generated file                   |
|-------------|----------------------------------------|----------------------------------|
| Claude Code | `dot_claude/CLAUDE.md.tmpl`            | `~/.claude/CLAUDE.md`            |
| Codex       | `dot_codex/AGENTS.md.tmpl`             | `~/.codex/AGENTS.md`             |
| opencode    | `dot_config/opencode/AGENTS.md.tmpl`   | `~/.config/opencode/AGENTS.md`   |
| PI          | `dot_pi/agent/AGENTS.md.tmpl`          | `~/.pi/agent/AGENTS.md`          |

To add a harness: write `<harness>.md` here and add a `.tmpl` that includes
`common.md`, `<harness>.md`, and `tail.md` in that order.

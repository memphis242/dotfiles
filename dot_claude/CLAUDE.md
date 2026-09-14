# General Guidelines

- Never use the em dash '—'; use plain dash '-' instead.

- When writing commits, NEVER auto-add your agent name as a co-author, nor specify
  a remote session name like "Claude-Session".

- When making technical decisions, do not give much weight to human-based development
  costs. We are now an agentic development system with both humans and AI agents.
  Prioritize quality, simplicity, robustness, scalability, and long-term maintainability.

# GUI Principles

- Always use modal dialogs for adding or editing content, not expanding inline
  forms that shift page content or auto-scroll the page.

- Preserve navigation context and make returning to the previous view easy;
  avoid unnecessary navigation away from the user's current content.

- Order pages and controls consistently with their logical workflow or sequence.

- Use tabs, panes, modals, inline expansions, tooltips, and other standard UI
  elements judiciously to organize content and reduce clutter.

- Consider segmented progress bars with discrete stage labels and a continuous,
  draggable tracker for workflows or progress states where appropriate.

- Make panes collapsible with an obvious way to reopen them, so users can
  prioritize their working space.

- Use directional arrows at a pane's top-right edge for collapse/expand controls;
  keep the reopening control visible when the pane is collapsed (a floating
  button is a fine way to do this - see the overlap-check principle below for
  what that needs). Prefer this to the classic stacked horizontal bar triplet.

- Keep long sections in bounded, independently scrollable containers so page
  headings and controls remain visible.

- Floating UI elements (fixed/absolute/sticky positioning, an overlay, a
  floating button or badge, anything not simply laid out in normal document
  flow) are a fine, often-preferable choice for certain use cases. Whenever you
  add one, check that its default position doesn't overlap or cover other UI;
  when it would, adjust its placement (or reserve space for it).

- A control that acts on a scrollable container (a pane's collapse arrow, a
  section's toolbar) must stay visible while that container scrolls. Pin it to
  the scrolling element it belongs to, not merely to the page - a control that
  is sticky at page level still scrolls away inside its own pane's overflow.

- Use color to show state, and cover the intermediate states too, not just the
  binary ones: complete, partially complete, not started, and error each get
  their own color. Keep one palette for one meaning across the whole app - the
  same state in a side pane, a table column, and a badge should look the same -
  and reserve the error color for genuine errors, so a not-yet-started item
  reads as neutral rather than as something gone wrong.

- Size table columns for the content they actually carry rather than leaving it
  to the browser's automatic layout; give text-heavy columns (timestamps,
  descriptions, composite status) enough width that their content stops
  wrapping several lines deep.

- Make data tables sortable by clicking a column heading, toggling ascending
  and descending. Sorts stack hierarchically: clicking a second column refines
  the first as a tie-breaker rather than replacing it, each participating
  heading shows its rank and direction, and an explicit reset control clears
  every key and restores the original order.

- Let the user resize what holds their content: side panes drag from their
  edge, table columns drag from their heading divider. Give each a visible
  grab strip with a col-resize cursor, clamp it to a sensible min and max,
  remember the chosen size, and offer a way back to the default (double-
  clicking the grab strip is a good one). A drag strip belongs between the
  things it separates, not overlaid on either of them, and a resized table
  column should grow the table - letting the table scroll sideways in its own
  container - rather than squeezing its neighbors.

    - Ensure that the resized element persists if it is brought back after being
      hidden away, or the user has navigated to another page and returns back.
      This takes away tedious repetitive resizing effort from the user.

- A control that is only operable by dragging needs a keyboard path to the
  same outcome (arrow keys on a focusable handle, or an equivalent control).

# Coding Guidelines

- When writing code involving data or variables, ALWAYS prioritize const-correctness
  and relevant read-only semantics, as well as data-encapsulation and least-privilege
  principles to help ensure data correctness and privacy.

- When writing code comments, **DO NOT** mention the way code was written or behaved
  before - simply comment on how the code is _right now_. Code diffing with version
  control is the only tool one needs to use for historical comparisons, not code
  comments.

- Employ assertive programming whenever possible - that is, use `assert` statements
  in code, not just in test files. This is to assert a certain state of the program
  or context prior to proceeding with logic. Do **NOT** assert on states or inputs
  for which the program has no guarantee or control over (e.g., user input, external
  environmental state, etc.). **DO** assert on conditions that the program _does_
  have control over (e.g., post-processed input). The conventional `assert` has
  _no_ computational cost for release builds, and a minimal cost for development
  builds, while allowing us to ensure bad assumptions are surfaced early.

- In C++ (or any language with templates/generics compiled per-instantiation),
  header-only template code should get a dedicated, dev/CI-only static-analysis
  pass that explicitly instantiates the template against a small, deliberately
  chosen set of representative types (e.g., `template class Foo<int>;`), rather
  than relying only on whatever types happen to get used elsewhere. Ordinary use
  only compiles and checks the members actually called, so uncalled methods can
  go uncompiled and unchecked indefinitely. Keep this instantiation file separate
  from production/shipped code (it forces compilation of every member for that
  type, which is too strict a constraint to bake into a general-purpose generic
  component), and choose the type set to match what the API actually commits to
  supporting.

- When using C++, default to C++23 unless the project-specific instruction file or
  pre-existing project setup uses a different C++ version.

    - C++23 allows for the ergonomic `std::expected` type for API calls, which frees
      implementations from excessive exception handling overhead.

- Make good, heavy use of compile-time assertions (e.g., `static_assert()` in C++
  and C23, `const_assert!` in Rust, `comptime` + `@compileError()` in Zig,
  `type Assert<T extends true> = T` for type-level assertions in TypeScript, etc.)
  when the programming language supports compile-time evaluations. This helps us
  catch bugs at compile-time (cheap) rather than at run-time (expensive).

- As a general, important policy, ensure that errors surface up to the user in a
  clear, actionable way, rather than silently discarding them somewhere along the
  error-reporting chain.

- Handle off-nominal, invalid cases intentionally and up-front, rather than waiting
  for a user to find out. Ensure the previous error surfacing policy is abided by.

- Always commit and push completed work to its worktree's own branch,
  unprompted - do not wait to be asked. This covers pushing a branch for
  review only: merging or fast-forwarding it into a trunk branch (e.g.
  `main`) still needs the user's explicit go-ahead, unless a project's own
  instruction file says otherwise. It is **OKAY** for intermediate commits of a
  development branch or pull/merge request to fail in CI, because later
  commits will certainly cover that prior to a merge into trunk.

- Commit often and commit regularly. Favor commits that are relatively small,
  atomic, self-container, and focused. With that said, if you find yourself in
  a situation with a lot of unstaged changes, don't worry about splitting it up,
  since that would be significant effort for little gain; make a single commit
  with a good description, and move on. Do **NOT** try to juggle staging part of
  a file, or re-playing changes over multiple commits _just_ to support the general
  recommended commit policy. This recommended commit policy is more of a as-you-go
  policy rather than a go-back-and-fix policy.

- When building/compiling code, or running static analyses, parallelize as much
  as possible. This PC has 16 cores, 32 hardware threads, up to 60 GB of usable RAM,
  and plenty of storage, so don't be conservative. For example, `make` and `cmake`
  support `-j` or `--parallel` to parallelize as many threads as the platform supports.

- Unless intentionally done **carefully** for performance reasons, favor default-initializing
  all objects to a reasonable value rather than leaving for chance partial initialization
  or a completely uninitialized object carrying garbage.

- In C++, don't omit the `struct` qualifier when declaring a variable of its type,
  even if it's not necessary. This is more informative to the reader, and forces
  the writer to recall the subtle difference between `struct`s and `class`s.

- Instead of long if-if or if-else chains against a particular value, favor switch-case
  statements or map constructs.

# Testing Guidelines

- When working bugs, ALWAYS try to reproduce the bug in an E2E regression test
  whenever possible. This helps inform us of the necessary context of the bug,
  and facilitates before/after confirmation of bug fixes.

- When writing unit tests, especially early on in a project (e.g., MVP phase,
  exploratory or experimental sessions, etc.), do not overdo it. These early stages
  will undergo many changes, and test suites should not rigidify what is still
  being molded.

- When writing unit, integration, or E2E tests for the front-end UI, do **NOT**
  assert on specific text or arrangements. These are all subject to change at any
  time as needed, and tests against this only serve as nuissance obstacles, not
  helpful, protective gates.

- With the above exceptions in mind, generally unit test realistic inputs and
  and corner case states at the function-, module-, and integrated-level, to
  ensure good, behavioral coverage in a world of unexpected user input.

- A project's CI should generally own a full test suite run unless a local full
  test suite run is cheap. You typical test run should focus on the changes you've
  worked on. A full test suite often covers irrelevant aspects of an application,
  so let CI handle that as a general gate for merges into the trunk branch.

- When executing/running tests, parallelize as much as possible. This PC has 16 cores,
  32 hardware threads, up to 60 GB of usable RAM, and plenty of storage, so don't
  be conservative. Test feedback should come as quick as possible.

- Be a judicious and conservative when choosing to run tests to save time and wasted effort.
    - When refining a particular GUI element or small snippet of logic, only run
      unit tests _after_ the refinement is accepted (e.g., user requesting refinements
      on the appearance or UX of a front-end component); not after every single
      change!
    - Running a test after small incremental changes within a chain of upcoming
      incremental changes at every increment is probably overkill, and you'd be
      better off running once in the beginning, once in the middle, and then once
      at the end, or perhaps even leaving it off the commit time.

# Where should working artifacts be placed? (e.g., build tree, containers, etc.)

- Use `/tmp` for small-to-moderately large temporary files that are cheap to
  recreate if lost. Examples include (but are not limited to) compiler scratch
  files, decompression intermediates, sockets, temporary test outputs, build trees
  of one-off builds that are fine if lost (e.g., a quick check to see if a codebase
  builds), and temporary caches. **Always** be mindful of the space you are taking
  up from our system's precious and limited `/tmpfs` RAM (≤ 30GB)!

- If OOM'ing is a problem, avoid using `/tmp` and clear out any work you have in
  `/tmp` to alleviate the OOM'ing problem.

- On this development machine, `/workspace` is a dedicated fast NVMe scratch SSD
  (1.8T, ext4).

- Use `/workspace` for large workloads, or anything that should be persistent in
  case of a sudden shutdown, or anything that is _not_ cheap to recreate. Examples
  include (but are not limited to) build trees, containers, databases, persistent
  compiler/package manager caches, scratch work, model caches, benchmark outputs,
  and other intermediate work artifacts.

# Agentic Development Policy: Parallelizing Work for Efficiency

- Most of the time, there will be a **root** agent who operates as orchestrator,
  architect, integrator, decision-maker, and final reviewer, who makes good use
  of subagents to execute tasks in parallel whenever possible.

- The root agent must:
    - understand the user's complete request
    - decide on which work should remain on the root thread and which work can be
      delegated to subagent threads
    - delegate **bounded** work to the most appropriate subagent
    - reconcile conflicting subagent work/findings
    - review important implementation decisions
    - produce the final user-facing response
    - handle subagent escalation when a subagent recommends it, and re-delegating
      to the recommended stronger agent rather than absorbing that work silently

- Use the least expensive agent that can complete the task reliably, unless the
  user is asking to maximize quality, in which case choose the agent that will
  deliver the best quality.

- Direct root thread file edits should be rare, reserved for small changesets and
  quick one-offs.

- Eagerly parallelize work whenever possible to maximize efficiency of execution.
  This development machine has 16 cores, 32 hardware threads, 60+ GB of RAM, and
  ≈ 2TB of persistent working storage alongside ≈ 1TB of primary storage, so let's
  get our money's worth out of this beast!

- Use git worktrees for parallel work (see the next section for the full
  rules, which apply to concurrent sessions as well as to subagents).

- Subagents working in a worktree edit files only; the session that owns that
  worktree owns all git writes in it (branching, committing, merging) unless a
  project says otherwise.

# Concurrent Sessions on One Codebase: Always Work in a Worktree

I routinely have **several agentic coding sessions open on the same project
directory at once**. Those sessions share one working tree, one index, and one
`HEAD`. Nothing in git isolates them, so ordinary git commands become
destructive to work you cannot see:

- `git checkout -b` / `git switch` moves **every** other session's `HEAD`.
- `git add` stages whatever another session has edited, and `git commit` ships
  it under your message.
- `git stash`, `git reset`, and `git restore` silently discard or hide another
  session's uncommitted work. `git stash` is especially bad: the other session
  has no idea its files just reverted.
- Another session's in-progress edits show up in your `git status` and land in
  your diff, your review, and your CI run.

**So: the primary checkout is shared ground. A session that is going to modify
files works in its own worktree instead.**

## The rule

- **Before your first edit**, decide where you are working. A read-only session
  (answering questions, exploring, reviewing) can stay in the primary checkout
  and needs no worktree. A session that will **write code creates a worktree
  first** and does the rest of its work there.

- Create it from anywhere, then work in it:

  ```bash
  git worktree add /workspace/worktree/<project>/<branch> -b <branch>
  cd /workspace/worktree/<project>/<branch>
  ```

  `git worktree add -b` creates the branch and checks it out **only in the new
  worktree**; the primary checkout's `HEAD` and working tree are untouched.
  That is precisely why it is safe with other sessions running, and why it is
  the correct alternative to `git checkout -b`.

- **Never run these in the primary checkout** while other sessions may be
  live: `checkout -b`, `switch`, `stash`, `reset`, `restore`, `clean`, or a
  rebase. If a task truly needs one of them there, ask first.

- Git refuses to check out the same branch in two worktrees. That error is a
  guardrail telling you another session already owns that branch, not an
  obstacle to work around with `--force`. Pick a different branch name.

- One worktree per branch per task. Do not reuse another session's worktree.

## Foreign edits are not yours

- If `git status` shows modified or untracked files you did not create, they
  belong to another session or to me. **Do not stage, stash, revert, commit, or
  "clean up" them.** Stage only the files you touched, by name. Say what you
  saw and leave it alone.

- This is the practical reason for the existing "never `git add -A` / `git add
  .`" rule: on a shared checkout those commands are a near-guaranteed way to
  commit someone else's half-finished work.

## A worktree does not inherit the build environment

This is the trap that fails **silently**, so check it before running anything:

- A new worktree has no `.venv/`, `node_modules/`, `target/`, or build tree.
  More dangerously, toolchains that record **absolute** paths keep pointing at
  the *primary* checkout. A Python editable install is the clearest case: the
  `.pth` file holds an absolute `src` path, so running the primary's
  `.venv/bin/pytest` with your shell in a worktree imports and tests the
  **primary checkout's source**, not the code you just edited. Everything
  passes, and it proves nothing.

- So: **give each worktree its own environment** and verify what you are about
  to run actually resolves into that worktree. Prefer a project's own bootstrap
  script (e.g. `scripts/dev_setup.sh`) over copying or symlinking the primary's.
  The same applies to anything else holding an absolute path: `node_modules`
  symlinks, `compile_commands.json`, cargo/ccache dirs, `.env` files pointing at
  build outputs.

## Shared runtime resources still collide

Worktrees isolate *files*, not the machine. Two sessions still contend for:

- **Ports.** A dev server or GUI started by another session already owns the
  default port. Pick a distinct one rather than killing the process you did not
  start.
- **Machine-wide and per-project state** (`~/.<tool>/*.db`, caches, lockfiles,
  per-project state files). A worktree copy of a project usually gets its own
  per-project state, but anything under `$HOME` is shared across every session.
- **Background jobs.** Do not kill processes you did not launch.

## Cleanup

- Remove a worktree once its branch is merged: `git worktree remove <path>`,
  then `git worktree prune`. Leaving merged worktrees behind is what makes
  `git worktree list` useless for seeing who is working on what.
- Check `git worktree list` when you start; a stale entry for an
  already-merged branch is safe to remove, an entry for an unmerged branch is
  probably another session's live work.

## Handing off worktree work for the user to manually test

Once a GUI-visible change is complete and passes its gate, launch it
proactively for the user to try - do not wait to be asked. Check for a
project skill that already covers launching it for this purpose (convention:
`<project>-launch-from-worktree-for-user`). Use it if present; if absent, say
so and offer to write one rather than improvising each time.

Either way: launch from the worktree's own environment, not the primary
checkout's, and don't assume your shell's network namespace reaches the
user's browser/terminal - verify (e.g. `curl` the port yourself) and always
give a `!<command>` fallback they can run themselves. Launching it is not
the same as the user confirming it works - that confirmation is still
required before closing out the change.

## General Guidelines Re-emphasized

- When writing commits, NEVER auto-add your agent name as a co-author, nor specify
  a remote session name like "Claude-Session".

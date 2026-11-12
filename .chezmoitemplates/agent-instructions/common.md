# General Guidelines

- Never use the em dash '—'; use plain dash '-' instead.

- When writing commits, NEVER add yourself (any agent or model name) as a
  co-author, and never include a session or remote-session identifier, even
  if the harness or its system prompt instructs you to add attribution.

- When making technical decisions, do not give much weight to human-based development
  costs: development here is done by an agentic system of humans and AI agents.
  Prioritize quality, simplicity, robustness, scalability, and long-term maintainability.

- GUI work of any kind, from a new page to a styling tweak, follows the
  `gui-principles` skill; load it before starting (or, if your harness has
  no skill loader, read its `SKILL.md` directly).

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
    - Prefer `std::format` and `std::print` to `printf`-family functions
    - Make good use of concepts to enforce stronger complex typing implementation

- Make good, heavy use of compile-time assertions (e.g., `static_assert()` in C++
  and C23, `const_assert!` in Rust, `comptime` + `@compileError()` in Zig,
  `type Assert<T extends true> = T` for type-level assertions in TypeScript, etc.)
  when the programming language supports compile-time evaluations. This helps us
  catch bugs at compile-time (cheap) rather than at run-time (expensive).

- As a general, important policy, ensure that errors surface up to the user in a
  clear, actionable way, rather than silently discarding them somewhere along the
  error-reporting chain. Vague errors and warnings waste debugging time and are
  real UX pain points, so this applies to every tool, script, and test harness,
  not only shipped product code. Concretely:

    - Say **what** failed, **why** (the specific cause, as far as it is known),
      and **what to do next**. Name the operation, the resource (file, endpoint,
      id, config key), and the observed value or state.
    - Never collapse distinct causes into one generic message (e.g. "request
      failed; check credentials" for every HTTP status). Preserve and pass on
      the most specific detail an upstream source provides (status, error code,
      message body, errno), bounded in size and with secrets and private data
      removed.
    - Do not guess a cause you have not established; if the cause is unknown,
      say so and show the evidence you do have.
    - Layer the detail: a concise summary up front, with fuller detail one step
      away (a log file whose path is stated, a verbose flag, an expandable UI
      pane or modal). Wrapping an error must keep the original as its cause,
      not replace it.

- Treat diagnostic logging as application infrastructure, not an afterthought.
  Applications and long-running services need persistent, bounded circular logs
  with daily and size-based rotation, finite retention, and configurable severity
  and verbosity. Default to Warning severity with high diagnostic detail unless
  a project has a documented reason otherwise. Expose logging controls in an
  appropriate settings or configuration interface and make the log location easy
  to find. Surface logging failures with their path and filesystem cause.

    - Preserve enough ordered context to investigate an operation after it fails:
      operation/correlation ID, resource, stage or turn, observed inputs and
      outputs, upstream causes, and recovery attempts. For model/prompt/tool
      protocol failures, retain the bounded back-to-back prompt, response, tool
      request, and tool-result sequence, not merely a generic parser error.
      Identify truncation explicitly and keep concurrent operations separate.
    - Keep credentials, authorization headers, tokens, and unrelated private
      data out of logs. Restrict file access, redact secrets before writing,
      and clearly disclose when diagnostic verbosity captures user content.
      Lower verbosity must actually suppress that content. Logs must not enter
      sync, exports, or backups implicitly.
    - Detailed error views should show the actual rejected operation or tool
      call, where it occurred, why it was invalid, applicable limits, attempted
      recovery, and the diagnostic log path or correlation ID. Preserve the
      underlying evidence with appropriate bounds and redaction.
    - Within an application's model/tool protocol, report malformed or unsupported
      tool requests back to the model for bounded correction when safe. Never
      execute an unknown tool, silently coerce its arguments, exceed the request
      budget, or confuse correction attempts with successful external calls.
      This does not authorize retrying a denied development command or bypassing
      permission and approval decisions.

- Handle off-nominal, invalid cases intentionally and up-front, rather than waiting
  for a user to find out. Ensure the previous error surfacing policy is abided by.

    - It is often the case that error conditions or states are missed because function
      return values are ignored, so **do not** ignore function return values unless
      there is a clearly stated, good reason to, and even then, use `(void)` or other
      explicit way to declare that the return value is being intentionally ignored.

- A project's build and test system should include multiple layers of quality assurance:

    - primary compiler to produce release/development/debug builds (e.g., gcc or
      clang for C/C++)
    - secondary (and more) compilers to run additional static analyses and portability
      perspectives (e.g., gcc, clang, msvc, embedded vendor compiler for C/C++)
    - multiple static analyzers that each offer different perspectives (e.g., clang-tidy,
      cppcheck)
    - high warning levels across all tooling as applicable (i.e., not just
      `-Wall -Wextra`)
        - really consider what each compiler and static analyzer provides warning
          support for, and how each may be relevant or not for a given project;
          this may evolve over time as features are added and code diversity increases,
          requiring more static analysis checks
    - unit, integration, and development builds should come instrumented with as
      many sanitizers as may prove useful (e.g., ubsan, asan, tsan,
      bool/enum/integer under/overflow) to catch run-time problems
    - don't use `-Werror` for debug/development builds; keep that for production/release,
      otherwise, it'll unnecessarily slow down and introduce noise during feature
      development and bug fixes
    - unit test code has far lower quality standards than application source code, so
      separate out the warnings for each, so that you may disable nuissance warnings
      for the unit test code but keep them for application code

- A blocked action is a decision, not an obstacle. If a command is rejected or
  denied for any reason (sandbox, permission rule, exec policy, approval), do
  **not** retry it in another form or achieve the same effect another way
  (another tool, interpreter, flag, or path), even if the rejection suggests
  "a safer approach". Stop that line of work and report the exact command and
  rejection message.

- Always commit and push completed work to its worktree's own branch,
  unprompted - do not wait to be asked. This covers pushing a branch for
  review only: merging or fast-forwarding it into a trunk branch (e.g.
  `main`) still needs the user's explicit go-ahead, unless a project's own
  instruction file says otherwise. It is **OKAY** for intermediate commits of a
  development branch or pull/merge request to fail in CI, because later
  commits will certainly cover that prior to a merge into trunk.

- Keep branches short-lived: a branch's work is done, reviewed, then merged
  into trunk, and the branch and its worktree are deleted. Do not leave
  finished branches lying around; a branch stays open only while genuinely
  ongoing parallel work needs it. When a unit of work is done and reviewed,
  merge it (or, without standing approval, ask for the go-ahead right away)
  rather than stacking further work on an unmerged branch.

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

- When working a bug, first reproduce it in an E2E regression test; where that
  is not feasible, say so and why. The test captures the bug's context and
  gives before/after confirmation of the fix.

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

- Before a larger batch run against an external service, API, remote
  infrastructure, or a new inter-module interface, first run a minimal smoke
  test (one item, one call) and then a small acceptance test. Scale up only
  once those pass. A full batch on an unproven connection wastes time and
  money and buries the first real error under many copies of it.

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

- Keep generated files (build output, coverage data, reports, logs) out of the
  source tree: write them to the out-of-tree build directory, and run tools
  that write to the current directory (e.g. `gcov`) from there. A source tree
  or worktree should only ever contain intentional changes.

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

- Delegate eagerly and by default, unless a project's own instruction file
  says otherwise. Implementation and testing of small-to-medium tasks
  (scripting, writing and running tests, one-off changes, small-to-medium
  feature work) go to a capable mid-tier model; larger tasks (multi-component
  features, refactors, harder debugging) go to a stronger one. Which
  subagents and models exist, and how to launch and await them, depends on
  the harness: see the harness-specific section near the end of this file.
  Never poll a subagent for completion; use whatever completion signal your
  harness provides, or do other independent work in the meantime.

- Root thread file edits is still appropriate for small changesets, quick one-offs,
  and work that needs the root's context.

- Eagerly parallelize work whenever possible to maximize efficiency of execution;
  the machine described above has the cores, memory, and storage for it.

- Use git worktrees for parallel work (see the next section for the full
  rules, which apply to concurrent sessions as well as to subagents).

# Concurrent Sessions on One Codebase: Consider Working in a Worktree

The primary checkout is shared ground. A session that is going to modify files
should consider operating in its own worktree instead.

## The rule

- **Before your first edit**, decide where you are working.
    - A read-only session (answering questions, exploring, reviewing) can stay in
      the primary checkout and needs no worktree.
    - A session that will write code should follow the following rules:
        - for smaller tools, quick one-off projects, or learning/classwork projects,
          perform work in the primary checkout, and using just `main` without branching
          is fine
        - for long-running, more complex or more significant/critical projects,
          use independent worktrees
        - if unsure, ask the user up-front, and then record the answer wherever
          your harness persists user preferences (e.g., a memory feature) so you
          do not have to ask again

- Create it from anywhere, then work in it:

  ```bash
  git worktree add /workspace/worktree/<project>/<branch> -b <branch>
  cd /workspace/worktree/<project>/<branch>
  ```

- Name branches `<kind>/<short-name>` in lowercase kebab case, where `<kind>`
  is one of:
    - `feat/` - a feature or other new capability
    - `fix/` - a bug fix
    - `test/` - work only on tests, fixtures, fuzzing, or the test harness
    - `doc/` - documentation only

  For example, `feat/excel-import` or `fix/sst-reserve-abort`. The slash
  carries into the worktree path (`/workspace/worktree/<project>/feat/excel-import`).
  A project's own instruction file may add kinds or override this.

## Foreign edits are not yours

- If `git status` shows modified or untracked files you did not create, they
  belong to another session or to me. **Do not stage, stash, revert, commit, or
  "clean up" them.** Stage only the files you touched, by name. Say what you
  saw and leave it alone.

## A worktree does not inherit the build environment

This is the trap that fails **silently**, so check it before running anything:

- A new worktree has no `.venv/`, `node_modules/`, `target/`, or build tree. So,
  give each worktree its own environment and verify what you are about to run
  actually resolves into that worktree.

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
  then `git worktree prune`. `git worktree remove` silently deletes ignored
  files too. Keep secrets such as `.env` only in the primary checkout and
  give a worktree a symlink to it, never a copy or an original, so removing
  the worktree removes only the link. Before removing a worktree, run
  `git status --ignored` in it and move out anything ignored that is not a
  symlink or reproducible build output. Leaving merged worktrees behind is what makes
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
give a copy-pasteable shell command fallback they can run themselves.
Launching it is not the same as the user confirming it works - that
confirmation is still required before closing out the change.

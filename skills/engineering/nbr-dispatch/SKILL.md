---
name: nbr-dispatch
description: Start a fresh coding agent in a Rex session (or Herdr workspace) for another repository. Use when the user asks to dispatch, spawn, sidekick, fork, or hand off a task to Pi, Claude Code, Codex, or another coding harness.
compatibility: Requires Rex or Herdr.
---

# Dispatch

Start a fresh coding-agent session in the target repository's Rex session, or its Herdr workspace outside Rex. Invoke this skill explicitly as `/skill:nbr-dispatch`.

When a session already runs in the target repository, ask the user whether to message it through `nbr-intercom` instead of starting a new one.

## Activation contract

A user-supplied `<skill name="nbr-dispatch">...</skill>` definition followed by an affirmative task request activates this skill, even when the user does not repeat `/skill:nbr-dispatch`. Treat the supplied definition as routing instructions, not conversation context.

Once active:

- Check `REX_SESSION` and `HERDR_ENV` before inspecting the target repository, Rex, or Herdr.
- Perform only routing checks required by this skill. Do not inspect implementation files or edit the target repository directly.
- If dispatch cannot run, report blocked. Never fall back to inline implementation.
- Task approval authorizes dispatch, not bypassing dispatch.

## Preconditions

This skill runs inside Rex or Herdr. Prefer Rex: when `REX_SESSION` is set, use the Rex path; otherwise, when `HERDR_ENV=1`, use the Herdr path. Check before inspecting either or resolving a target:

```bash
test -n "${REX_SESSION:-}" || test "${HERDR_ENV:-}" = 1 || {
  printf '%s\n' 'Dispatch must run inside Rex or Herdr.' >&2
  return 1 2>/dev/null || exit 1
}
```

## Resolve and confirm the target

Establish an exact Git checkout before creating a pane or starting an agent.

- When the brief says “here”, “this repository”, or otherwise clearly names the current checkout, use the current Git root as the candidate.
- When it refers to another project, infer a candidate from Git repositories under `repos_root`: the folder the user's agent instructions name for their checkouts, else `~/repos`. Include ordinary checkouts and linked worktrees, deduplicate their canonical Git roots, and use the brief and current session context to choose the best candidate.
- A direct path in the brief is also a candidate.

Use this inventory when another project needs to be inferred:

```bash
find "$repos_root" \( -type d -name .git -prune -print \) -o \( -type f -name .git -print \) |
  while IFS= read -r git_entry; do
    git -C "$(dirname "$git_entry")" rev-parse --show-toplevel
  done | sort -u
```

Canonicalize the candidate before presenting it:

```bash
target_repo=$(git -C "$candidate" rev-parse --show-toplevel)
target_repo=$(cd -- "$target_repo" && pwd -P)
```

Ask the user to confirm the resolved absolute target path in the current conversation. For example: “I resolved this to `/home/you/code/acme/project`. Dispatch there?” Do this even for the current checkout, unless a calling skill passes a target the user already confirmed. If no candidate is clear or several candidates tie, ask one focused question for the path. Do not open a repository picker and do not create a pane from an unconfirmed inference.

## Name a worktree

Only when the brief or the calling skill asks for a new worktree: name its topic and branch by the worktree convention in the user's global agent instructions, and confirm them with the user, unless the brief or calling skill already did. The worker never creates one; `nbr-session-setup` does, and a fresh worktree is clean, so skip the state check below. Tell the worker that its location is settled and is that worktree.

## Check the target worktree

After the user confirms the path, check its state before creating a session, workspace, or pane:

```bash
git -C "$target_repo" status --short
```

When the output is empty, continue. When it is not, show the changed-file summary and ask the user to choose one action:

- **Launch anyway**: start the worker and include the pre-existing status in its prompt. The worker must leave those changes alone unless the task explicitly requires them.
- **Write a handoff**: return a copy-ready handoff containing the target, task, dirty-state summary, and suggested next step. Do not launch an agent.
- **Create a tracker issue**: inspect the `origin` remote and identify its GitHub or Bitbucket target. Ask for confirmation again before creating an external issue. Use an authenticated, directly applicable tracker tool only when available. Otherwise return the copy-ready handoff. Do not infer a Jira project from a remote.
- **Stop**: make no change.

## Resolve the harness

Use an explicit `pi`, `claude`, or `codex` from the brief. Otherwise use the harness running the current session. If it cannot be identified, ask which of `pi`, `claude`, or `codex` to use. Do not open a harness picker.

## Launch

Build a concise child prompt containing the confirmed repository, the task (a calling skill's brief goes in verbatim), relevant current-session context, dirty-state summary when applicable, and the instruction to implement, verify, and stop. Do not paste the raw conversation.

Send these boundary instructions literally, alongside the task details:

```text
You are the dispatched worker.
Work directly in the selected repository and in this pane.
Do not launch reviewers or other agents.
Do not invoke Pi subagent tools, workflow orchestration, worktrees, or Rex or Herdr commands.
Do not inspect or switch to another repository.
Never push to the default branch; changes reach it through a pull request.
Follow directly applicable task skills in this pane; ignore unrelated skills.
Pre-existing changes: <clean, or exact status summary>
```

When the task builds or tests tooling for Rex or Herdr itself, send the line `Do not invoke Pi subagent tools, workflow orchestration, or worktrees.` in place of the boundary line that names them, followed by `Run Rex or Herdr commands only to test this task's changes, and close only sessions or panes you created.`

The child may follow directly applicable task skills in this pane, but must not delegate this task to another agent or reviewer.

Tell the child that the handoff below closes the dispatched task: its reply when that task is done contains only
this copy-ready handoff. After that the user works with it directly, and it answers in plain conversation, writing
a new handoff only when the user asks for one:

```text
Repository: <absolute path>
Task: <what was requested>
Status: <complete, blocked, or in progress>
Changes: <files and behavior changed>
Verification: <commands run and results>
Remaining issues: <none or exact unresolved items>
Suggested next step: <a recommendation or sensible options for continuing>
```

When both this session and the child run Claude Code, the child reports back through cross-session messages. Take this session's name from the first line of `ListAgents` and add to the child prompt:

```text
Report back to the dispatching session <name> with SendMessage: one line when you start ("On it: <task>"), and the handoff when you finish.
```

Write the child prompt to a scratch file with the Write tool, so it never passes shell quoting. Then run `nbr-session-setup` with the confirmed repository, the worktree topic and branch when one was named, install `normal` for a new worktree, the worktree's label (or the repository's folder name for a main checkout), and the agent: the prompt file and the harness; setup names the agent. Setup stops on a denial or dialog; report what it returns as blocked. When it stops after creating a worktree, name that worktree so the user can remove it.

Do not add `--wait`, wait for child completion, read child output, summarize its work, or close its pane. Return a short launch receipt with the confirmed repository, Rex session or Herdr workspace, pane, agent label or name, and that the child will leave its handoff in its pane. When the child's messages arrive, pass each one to the user in a line or two.

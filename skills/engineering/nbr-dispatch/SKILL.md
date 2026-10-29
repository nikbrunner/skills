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

## Create a worktree

Run this step only when the brief or the calling skill asks for a new worktree. The dispatcher creates it; the worker never does.

Name the branch, folder and Rex session label by the worktree convention in the user's global agent instructions, when they define one. Follow the target repository's own `AGENTS.md` or a start skill it names for the base branch and install step. Without them, derive the primary branch and create a sibling:

```bash
base=$(git -C "$target_repo" symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
: "${base:?origin/HEAD is unset; ask the user for the base branch}"
worktree_path="$(dirname "$target_repo")/<name>"
git -C "$target_repo" fetch origin "$base"
git -C "$target_repo" worktree add "$worktree_path" -b "<name>" "origin/$base"
target_repo=$(cd -- "$worktree_path" && pwd -P)
```

Confirm the name with the user before creating it, unless the brief or calling skill already confirmed it, then run the repository's install step in the new tree. The new `$target_repo` holds for every later step. A fresh worktree is clean, so skip the state check below. Tell the worker that its location is settled and is this worktree. If dispatch stops after this point, name the created worktree in the report so the user can remove it.

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

## Select the Rex session

Skip this section outside Rex.

Session labels are repo names or PR titles, so match on working directories, not labels. For each session from `rex ls --json`, list its panes with `rex block ls -s <session> --json` and read each pane's process with `rex block call -s <session> -b <block> process`. A session matches when a pane's `.foreground.cwd`, or its shell ancestor's `cwd`, exactly equals `$target_repo`. If several sessions match, ask one focused question naming their labels and IDs.

Label the new pane `Agent <next roman numeral>`, counting the `Agent …` labels already in that session (`Agent I`, `Agent II`, …). `nbr-intercom` finds agent panes by that label.

For one matching session, read its `active_window_id` and that window's `focused_block_id` from `rex session inspect <session> --json`, then split that pane, choosing `right` or `below` from its layout `rect`. The harness and child prompt come from the sections below; pass the prompt as the harness's first argument, never through `rex send`:

```bash
child=$(rex split -s "$session" -b "$anchor_block" --split="$direction" -c "$target_repo" \
  --label "$agent_label" --focus=false --json -- "$harness" "$child_prompt")
child_id=$(printf '%s\n' "$child" | jq -er '.block_ids[0]')
```

When no session matches, create one for the target and start the worker in its first pane. `session_label` is the worktree's label from the worktree convention, or the repository's folder name for a main checkout:

```bash
created=$(rex new "$session_label" -c "$target_repo" --window Agents --json -- "$harness" "$child_prompt")
session=$(printf '%s\n' "$created" | jq -er '.session_id')
child_id=$(printf '%s\n' "$created" | jq -er '.initial_windows[0].block_ids[0]')
rex block rename -s "$session" "$child_id" 'Agent I'
```

Parse every Rex ID from JSON output. Never guess IDs or rely on UI focus. The worker starts with its prompt, so skip the Herdr launch commands below.

## Select the Herdr workspace

Skip this section inside Rex.

List the open workspaces:

```bash
herdr workspace list
```

An open workspace matches only when its `worktree.checkout_path` exactly equals `$target_repo`. A workspace for a linked worktree or another checkout of the same repository does not match. If several workspaces match, ask one focused question naming their labels and IDs. Do not use a picker.

For one matching workspace:

1. Read its active tab ID from the workspace result.
2. List its panes with `herdr pane list --workspace <workspace-id>`.
3. Select a pane from that active tab and inspect its layout with `herdr pane layout --pane <pane-id>`.
4. Split that explicit pane, choosing `right` or `down` from its geometry. Set the new pane's cwd to `$target_repo` and keep focus unchanged.

```bash
child=$(herdr pane split "$workspace_pane_id" --direction "$direction" --cwd "$target_repo" --no-focus)
child_id=$(printf '%s\n' "$child" | jq -er '.result.pane.pane_id')
```

When no workspace matches, create an unfocused target workspace and use its root pane directly:

```bash
target_label=$(basename "$target_repo")
created=$(herdr workspace create --cwd "$target_repo" --label "$target_label" --no-focus)
child_id=$(printf '%s\n' "$created" | jq -er '.result.root_pane.pane_id')
```

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

Tell the child that its final response must contain only this copy-ready handoff:

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

In Herdr, run these commands from the current pane. Parse every Herdr ID from JSON responses. Never guess IDs or rely on UI focus.

```bash
agent_name="dispatch-$(date +%s)"
herdr agent start "$agent_name" --kind "$harness" --pane "$child_id"
herdr agent prompt "$agent_name" "$child_prompt"
```

A pane whose shell is still starting, or still running a command sent with `herdr pane run`, makes `agent start` fail with `agent_pane_busy`. Wait a second and retry, up to three times, before reporting it blocked.

Do not add `--wait`, wait for child completion, read child output, summarize its work, or close its pane. Return a short launch receipt with the confirmed repository, Rex session or Herdr workspace, pane, agent label or name, and that the child will leave its handoff in its pane. When the child's messages arrive, pass each one to the user in a line or two.

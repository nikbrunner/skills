---
name: nbr-session-teardown
description: Tear down a work session once its work is merged or done: checks that nothing gets lost, stops its servers, removes its worktree and branch, and closes the Rex session or Herdr workspace. Use when a skill or the user is done with a session, worktree, PR review or dispatched task, or asks to clean one up.
compatibility: Requires Rex or Herdr.
---

# Session teardown

Clears what a session left behind, in the reverse order of `nbr-session-setup`. Nothing that is not yet pushed or reported gets thrown away: the checks come first, and any finding stops the teardown before the first change.

## Inputs

A Rex session or Herdr workspace, or a worktree path. From either, resolve the other: the session whose panes have the worktree as `cwd` (as `nbr-session-setup` matches them), or the worktree those panes sit in. A main checkout stays: only a linked worktree, whose `git rev-parse --git-common-dir` is not its own `.git`, gets removed. Its primary checkout holds that common dir:

```sh
primary=$(dirname "$(git -C "$worktree" rev-parse --path-format=absolute --git-common-dir)")
```

## 1. Check

Collect every finding before stopping, so one report names them all:

- **Uncommitted changes**: `git -C "$worktree" status --short` is not empty.
- **Unpushed commits**: `git -C "$worktree" log --oneline HEAD --not --remotes=origin` lists any. Name each commit.
- **Agents**: each `Agent …` pane whose foreground is not a shell runs an agent, except the caller's own pane (`$REX_BLOCK`). Read its state with `rex block call -s "$session" -b "$block" program_status`: `working` or `blocked` is mid-task, a finding.

A live agent that is `done` or `idle` gets asked for its report to Bob first, unless the caller says it already reported: send it `/nbr-report-to-bob`, then wait until its state goes back to `done`.

```sh
rex send -s "$session" -b "$block" '/nbr-report-to-bob' && rex send-key -s "$session" -b "$block" enter
```

Any finding: stop, report each one with its pane or commit, and change nothing. Done when every check came back clean.

## 2. Stop the servers

For each pane in the Shells tab whose foreground is not a shell, send `ctrl+c` and wait until the shell is back:

```sh
rex send-key -s "$session" -b "$block" ctrl+c
```

When that pane ran Docker Compose (`ps -o command= -p <foreground pid>` names `docker compose` or `docker-compose`), run `docker compose down` in its `cwd` afterwards. A pane still busy after a second `ctrl+c`: stop and report it.

## 3. Remove the worktree and branch

```sh
branch=$(git -C "$worktree" branch --show-current)
git -C "$primary" worktree remove --force "$worktree"
git -C "$primary" branch -d "$branch"
```

`--force` because ignored files such as `node_modules` make a plain `remove` refuse; the checks in step 1 are what protect the work.

`branch -d` refuses a branch not merged into its upstream or `HEAD`. Use `-D` only when `git -C "$primary" log --oneline "$branch" --not --remotes=origin` is empty, since origin then holds every commit. Otherwise keep the branch and name it in the report.

## 4. Close the session

Last, since the session may hold the caller:

```sh
rex kill "$session"
```

Herdr: `herdr workspace close <id>`.

When the session is the caller's own (`$REX_SESSION`), nothing after the kill runs: report first, then run steps 3 and 4 as one command, `git … worktree remove --force … && git … branch -d … && rex kill "$session"`.

## Return

What was removed (servers, worktree, branch, session), and what was kept and why.

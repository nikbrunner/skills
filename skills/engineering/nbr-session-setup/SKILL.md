---
name: nbr-session-setup
description: Set up a work session for a repository: worktree, dependency install, Rex session or Herdr workspace, and optionally a coding agent started from a brief in its Agents tab. Use when a skill or the user needs another repo, branch or PR ready to work in, such as a dispatch, a PR review, or Bob handing out work.
compatibility: Requires Rex or Herdr.
---

# Session setup

Prepares a place to work: the checkout, the session around it, and, when asked, an agent running a brief there. The caller has already confirmed the target with the user; this skill asks nothing. Anything it cannot do cleanly, it stops on and reports.

Prefer Rex: when `REX_SESSION` is set, use the Rex sections; otherwise, when `HERDR_ENV=1`, use the Herdr sections. Neither set: stop and say so.

## Inputs

- **Repo**: an absolute Git checkout, the primary one when a worktree is wanted.
- **Checkout**, one of:
  - none: work in the repo as it stands.
  - **source branch** of a PR: a worktree tracking `origin/<source>`.
  - **topic**: a new branch and worktree from the primary branch. The caller passes the branch name.
- **Topic** and **label**: name the worktree folder and the session by the worktree convention in the global agent instructions. The caller passes the label, since it carries ticket keys and PR numbers.
- **Install**: `normal`, `no-scripts` for code nobody has reviewed yet (a PR under review), or `skip`.
- **Agent**, optional: a brief file and a harness (`claude`, `pi`, `codex`). Setup names the agent.

## Worktree

Skip this section without a source branch or topic; `worktree` is the repo itself.

The folder is `"$(dirname "$repo")/<repo folder>-<topic>"`. Look for an existing one first:

```sh
git -C "$repo" fetch origin
git -C "$repo" worktree list --porcelain
```

- A worktree already has the branch: reuse it. When its `git status --short` is empty, `git pull --ff-only`; otherwise leave it as it stands and return its status.
- A local branch exists without a worktree: `git worktree add "$worktree" "<branch>"`, then `git merge --ff-only origin/<branch>` for a source branch. A failed fast-forward means local commits the remote lacks: keep them and return them.
- Neither, for a source branch: `git -C "$repo" worktree add "$worktree" -b "<source>" --track "origin/<source>"`.
- Neither, for a topic: branch from the primary branch.

  ```sh
  base=$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
  git -C "$repo" worktree add "$worktree" -b "<branch>" "origin/$base"
  ```

  `origin/HEAD` unset: stop and ask the caller for the base branch.

## Install

Run the install step the repo's `AGENTS.md` or its start skill names, in each package root the caller names, else in the worktree root. `no-scripts` adds the package manager's flag that skips lifecycle scripts (`npm ci --ignore-scripts`), so unreviewed code stays unrun. A reused worktree whose lockfile did not change skips it. Done when each root has its dependencies installed.

## Rex session

Find the session in `rex ls --json`: first by the label, then by working directory, where a session matches when one of its panes (`rex block ls -s <session> --json`, then `rex block call -s <session> -b <block> process`) has a `.foreground.cwd`, or a shell ancestor `cwd`, equal to `$worktree`. Several matches: stop and return their labels and IDs.

None matches: create it with Helm's layout (an Agents tab with `Agent I` and `Agent II`, Edit, and Shells with four panes). `helm-rex create` builds it without switching the app:

```sh
created=$(helm-rex create "$worktree" --label "$label" --json)
session=$(printf '%s\n' "$created" | jq -er '.session_id')
```

Stop when it fails.

## Rex agent

Skip this section without an agent.

Name the agent first. The names are a loop of ten that survive dictation: Ben, Clara, Emma, Felix, Greta, Lena, Max, Pink, Sadie, Sophie. Take the first one after the last name in use, in loop order, that no live agent holds (`ListAgents`, `rex ls`). Then put the name in front of the session's label: `rex session rename "$session" "$name · $label"`. The agent is addressed by that name from then on.

Find the pane in the session's Agents tab, the window named `Agents`:

1. The first `Agent …` pane whose foreground process is a shell (`.foreground.name` is `zsh`, `bash` or `fish`). For a session just created, `jq -er '.tabs[].panes["Agent I"] // empty'` on `$created` gives `Agent I`.
2. Every Agent pane busy: split one, choosing `right` or `below` from its `rect` in `rex session inspect "$session" --json`, labelled with the next roman numeral. The split opens an interactive shell:

   ```sh
   rex split -s "$session" -b "$anchor" --split="$direction" -c "$worktree" \
     --label "Agent <next numeral>" --focus=false --json
   ```

3. No Agents tab: `rex window new -s "$session" Agents -c "$worktree" --keep-open --json -- <launch command>`, with the command as its arguments, and take the pane from `.block_ids[0]`. A command started by Rex runs in the login shell's environment, so it carries every variable itself.

Start the agent by typing one line into the shell, so the user's shell functions and environment hold and the brief, read through command substitution, never passes shell quoting. Claude runs on the caller's config: when `CLAUDE_CONFIG_DIR` is set here, the line carries it and the variables that come with it.

```sh
# caller has CLAUDE_CONFIG_DIR
line="env CLAUDE_CONFIG_DIR='$CLAUDE_CONFIG_DIR' CLAUDE_CODE_NO_FLICKER=1 claude -n '$name' \"\$(cat '$brief')\""
# caller runs on the default config
line="claude -n '$name' \"\$(cat '$brief')\""
# pi or codex
line="$harness \"\$(cat '$brief')\""

rex send -s "$session" -b "$block" "$line" && rex send-key -s "$session" -b "$block" Enter
```

Check the pane with `rex capture -s "$session" -b "$block" | tail -25`. Done when the agent shows the brief running. A denied command, or a trust, login or permission dialog in the pane, stops here: return the session, the pane, the brief path and the exact denial or dialog, and leave it to the user.

## Herdr workspace

Skip this section inside Rex.

An open workspace from `herdr workspace list` matches only when its `worktree.checkout_path` exactly equals `$worktree`. Several match: stop and return their labels and IDs. None matches: create one, unfocused:

```bash
created=$(herdr workspace create --cwd "$worktree" --label "$label" --no-focus)
pane=$(printf '%s\n' "$created" | jq -er '.result.root_pane.pane_id')
```

For an agent in an existing workspace, use its Agents tab, the first one Helm's layout creates; only a workspace without one falls back to the active tab. List its panes with `herdr pane list --workspace <id>`, read one's geometry with `herdr pane layout --pane <id>`, and split it `right` or `down`:

```bash
child=$(herdr pane split "$pane" --direction "$direction" --cwd "$worktree" --no-focus)
pane=$(printf '%s\n' "$child" | jq -er '.result.pane.pane_id')
```

Start the agent in that pane:

```bash
herdr agent start "$name" --kind "$harness" --pane "$pane"
herdr agent prompt "$name" "$(cat "$brief")"
```

A pane whose shell is still starting makes `agent start` fail with `agent_pane_busy`. Wait a second and retry, up to three times, before stopping.

## Return

The worktree path, whether it was created or reused (with its status when not clean), the session or workspace with its label, the pane, and the agent's name. Parse every ID from JSON output; never guess one or rely on UI focus.

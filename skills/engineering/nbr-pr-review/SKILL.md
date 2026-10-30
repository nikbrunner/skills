---
name: nbr-pr-review
description: Review a pull request from its GitHub link in a session of its own: worktree, Rex session, and a Claude worker that reports against nbr-repo-conventions. Use when Nik asks to review a PR, or a host-specific review skill builds on it.
argument-hint: "<GitHub pull request URL>"
compatibility: Requires Rex, gh, and nbr-session-setup.
---

# Review a PR

This session prepares the ground and launches a worker. The worker reviews in its own Rex session, where the repo's own skills load, and leaves its report in its pane. This session asks Nik nothing; the worker's only question comes after its report.

A host-specific skill (`imfg-pr-review` for Bitbucket) runs these steps with its own reading of the PR and its own slots in the brief; everything it does not replace holds as written here.

## 1. Resolve the PR

The URL has the shape `https://github.com/<owner>/<repo>/pull/<number>`. Read the PR:

```sh
gh pr view "<URL>" --json number,title,body,state,headRefName,baseRefName,isCrossRepository,url
```

A state other than `OPEN` stops here. So does `isCrossRepository: true`: a PR from a fork has no `origin/<source>` to track; say so in one line.

Name the PR's subject in two to four words from its title and description, the way Nik would say it out loud: `playwright-e2e` for "feat(e2e): add playwright end-to-end tests", `project-members` for "Feat/CP-230 members and roles in projects". Drop commit-type prefixes, ticket keys, and filler. That `<topic>` names everything this skill creates:

- worktree folder and Rex session label: the worktree convention in the global agent instructions, e.g. `~/repos/nikbrunner/nbr.haus-project-members` labelled `Project members · PR 15`
- agent name: `review-<number>-<topic>`, cut to 32 characters

The branch keeps the PR's own name, since it tracks `origin/<source>`.

Find the primary checkout: the repo under `~/repos` whose `origin` points at `<owner>/<repo>` (SSH or HTTPS) and whose `git rev-parse --git-common-dir` is its own `.git`. Linked worktrees share the remote, so several paths can match; the common dir picks the one primary. None found: stop and name the remote Nik needs to clone.

## 2. Judge the shape

```sh
git -C "$primary" fetch origin "<source>" "<target>"
git -C "$primary" diff --stat "origin/<target>...origin/<source>"
```

From the stat, plus the title and description, judge the PR's **shape**, which decides what the worker checks:

- **app**: it changes what the project does: its source, routes, components, styles, commands. The full brief.
- **adjacent**: it changes how the project is built or checked without changing what it does: tests, build or CI config, docs, dependency bumps. Name the convention topics that govern it (`testing` for tests, `tooling` and `npm-project` for config, `docs-structure` for docs, `dependencies` for bumps), and drop the design step from the brief.

A mixed PR takes the app shape. The topics are those of `nbr-repo-conventions` that the diff touches; a repo those topics do not cover (a Rust, Go or Lua project) is reviewed against its own `AGENTS.md` and the idioms of its language, and the brief says so.

## 3. Launch the worker

Run `nbr-session-setup` without an agent first, with:

- the primary checkout, and the PR's source branch, with `<topic>`
- the label `<Topic in words> · PR <number>`
- install `no-scripts`, in the package roots the diff touches: this install is part of the skill, and the PR's own code stays unrun

It returns the worktree, its state when reused (local commits the remote lacks, uncommitted changes), and the session. Fill the brief in [`BRIEF.md`](BRIEF.md) with them and write it to a scratchpad file with the Write tool, so its backticks and the author's description never pass through shell quoting. Then run setup's agent step for that session: the brief file, harness `claude`, the agent name.

Setup stops on a denial or a trust or login dialog: give Nik the session, the pane, the brief file path, and the exact denial or dialog, and leave the rest to him.

Return a launch receipt: PR title, worktree path, Rex session, agent name.

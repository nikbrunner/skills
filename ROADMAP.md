# Roadmap

Where this repo is heading: one home for my agent setup, with dots keeping only machine wiring.

## Become the `agents` repo

The repo grows from skills into the content of my agent setup, mirroring `imfusion/brunner/agents` on the work side.

- Rename the repo to `agents`. GitHub redirects the old URL, so `npx skills add nikbrunner/skills` keeps working.
- Move the global `AGENTS.md` and the subagents (`common/.agents/AGENTS.md` and `common/.agents/agents/` in dots) into
  `global/`. They never sit at the repo root: a root `AGENTS.md` is the project instruction file for agents working in
  this repo.
- `install.sh` links them where `symlinks.yml` in dots links them today: `~/.claude/CLAUDE.md`, `~/.claude-work/CLAUDE.md`,
  `~/.pi/agent/AGENTS.md`, `~/.claude/agents`, `~/.claude-work/agents`.
- `~/.agents` stops being a symlink into dots and becomes a directory `install.sh` owns.

Open question: does tool config move too (Claude `settings.json`, hooks, keybindings, `.pi`, `.codex`)? Content first;
tool config follows only if the split between the two repos gets in the way.

## Empty the dots skills folder

`~/.agents/skills` still lives in dots and holds a few pieces this repo doesn't manage:

- `plannotator-annotate`, `-last`, `-review` from the Plannotator installer, and `tldraw-offline` and `terminal-browser`
  from their apps. They can stay untracked, since their tools reinstall them.
- The `imfg-*` links into the ImFusion agents repo. That repo needs its own install step for them first.

## Port the web-ui workflow improvements

The web-ui project skills have moved ahead of their generic versions here. Generic parts to bring over:

- Commit and changelog: a light pre-commit next to a separate CI-parity pass, the changelog checked at commit time,
  breaking changes that still compile, the category read from the diff.
- `nbr-audit-docs`: a change-to-candidate-docs table, "a doc that repeats a code fact points to the code", and a
  fallback to the last five commits.
- Release: approval right before tagging.
- Worktree start and teardown: base branch from `origin/HEAD`, install in a new worktree, rebase-verify-fast-forward
  merges with no merge commits or force pushes.
- `nbr-record-clip`: measure the loop cycle in the page instead of passing it by hand.

## Session skills, and Bob at user level

The plan lives in [`plans/session-skills-and-bob.md`](plans/session-skills-and-bob.md).

## Make the engineering skills read well for colleagues

- `nbr-repo-conventions`, `-setup` and `-audit` speak of "personal projects"; the conventions apply to any TypeScript web
  project I control.
- Descriptions written in my name ("Nik's planning flow") read oddly in someone else's agent.

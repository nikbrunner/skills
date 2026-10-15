# skills

My agent skills for Claude Code, Pi, Codex and anything else that reads `SKILL.md`. They encode how I plan, commit, open PRs and set up repos, so they are opinionated by design. Take what fits.

## Install

All of them:

```sh
npx skills add nikbrunner/skills
```

One of them:

```sh
npx skills add nikbrunner/skills --skill nbr-git-commit
```

`npx skills add nikbrunner/skills --list` shows everything with its description.

### Working copy

To edit the skills and use them live, clone the repo and link them in:

```sh
git clone https://github.com/nikbrunner/skills ~/repos/nikbrunner/skills
~/repos/nikbrunner/skills/setup.sh                     # links into ~/.agents/skills
~/repos/nikbrunner/skills/setup.sh ~/.claude/skills    # or any skill directories you name
```

`setup.sh` links every folder in `skills/` into each target, removes links whose skill no longer exists, and never replaces a real file or directory. Run it again after adding or removing a skill.

## Skills

| Skill                    | What it does                                                                      |
| ------------------------ | --------------------------------------------------------------------------------- |
| `nbr-plan`               | Grill an idea to shared understanding, then write a plan for a PO and a developer |
| `nbr-afk-implementation` | Finish approved implementation work autonomously while you are away               |
| `nbr-git-commit`         | Commit with selective staging, a review pass and an approval gate                 |
| `nbr-git-commit-buckets` | Sort a dirty working tree into atomic commits                                     |
| `nbr-git-commit-rebuild` | Rewrite a run of commits into clean atomic ones                                   |
| `nbr-create-pr`          | Draft and publish a pull request                                                  |
| `nbr-audit-docs`         | Find documentation a diff made stale                                              |
| `nbr-how-to-test`        | Write a black-box acceptance testing checklist                                    |
| `nbr-repo-conventions`   | Conventions for personal projects, by topic                                       |
| `nbr-repo-setup`         | Set up repo tooling from those conventions                                        |
| `nbr-repo-audit`         | Audit a repo against those conventions without changing it                        |
| `nbr-glossary`           | Extract a DDD-style glossary from the conversation                                |
| `nbr-handoff`            | Compact the conversation into a handoff document                                  |
| `nbr-self-reflection`    | Turn a correction into a durable improvement                                      |
| `nbr-slow-mode`          | Slow down for learning and human decisions                                        |
| `nbr-record-clip`        | Record terminal, browser or app motion as a looping WebP                          |
| `nbr-nvim`               | Neovim and Lua development workflow                                               |
| `nbr-dispatch`           | Start a coding agent for another repo in a Herdr workspace                        |
| `nbr-things`             | Manage Things 3 tasks on macOS                                                    |
| `nbr-changelog-things`   | Log a day's development work as completed Things items                            |

Some skills need tools beyond an agent harness: `nbr-things` and `nbr-changelog-things` need Things 3 on macOS, `nbr-dispatch` needs [Herdr](https://github.com/herdrdev/herdr), and `nbr-plan` reviews plans in [Plannotator](https://github.com/backnotprop/plannotator).

A few skills call other skills when they are installed: [`humanizer`](https://github.com/blader/humanizer) for prose in plans, PRs and changelogs, `plannotator-annotate` (ships with Plannotator) for plan review, and `documentation-writer` for doc fixes.

## License

MIT

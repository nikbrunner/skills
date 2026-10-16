# Engineering

How I plan, commit, open PRs and set up repos. Works in any codebase.

```sh
npx skills add https://github.com/nikbrunner/skills/tree/main/skills/engineering
```

## Requires

Install these first. Each skill names its own requirements in the `compatibility` field of its `SKILL.md`.

| Dependency                                                     | Install                                         | Used by                                                       |
| -------------------------------------------------------------- | ----------------------------------------------- | ------------------------------------------------------------- |
| [`humanizer`](https://github.com/blader/humanizer)             | `npx skills add blader/humanizer`               | `nbr-plan`, `nbr-create-pr`                                   |
| [`documentation-writer`](https://github.com/github/awesome-copilot) | `npx skills add github/awesome-copilot --skill documentation-writer` | `nbr-git-commit`, and through it `-buckets` and `-rebuild` |
| [Plannotator](https://github.com/backnotprop/plannotator)      | see its README, it ships `plannotator-annotate` | `nbr-plan`                                                    |
| `gh` or [`bkt`](https://github.com/avivsinai/bitbucket-cli)    | your package manager                            | `nbr-create-pr`                                               |

`nbr-record-clip` needs ImageMagick, plus VHS, ffmpeg or Playwright depending on what it records.

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

# skills

My agent skills for Claude Code, Pi, Codex and anything else that reads `SKILL.md`. They encode how I plan, commit, open PRs and set up repos, so they are opinionated by design. Take what fits.

## Install

The skills sit in two folders. [`engineering`](skills/engineering) covers coding work and the tools it runs on. [`personal`](skills/personal) covers life outside the code. [Skills](#skills) lists what each one needs installed first.

All of them:

```sh
npx skills add nikbrunner/skills
```

One folder:

```sh
npx skills add https://github.com/nikbrunner/skills/tree/main/skills/engineering
```

One skill:

```sh
npx skills add nikbrunner/skills --skill nbr-git-commit
```

`npx skills add nikbrunner/skills --list` shows everything with its description.

### Working copy

To edit the skills and use them live, clone the repo and link them in:

```sh
git clone https://github.com/nikbrunner/skills ~/repos/nikbrunner/skills
~/repos/nikbrunner/skills/install.sh
```

`install.sh` links every skill folder in `skills/<group>/` into `~/.agents/skills`, and points `~/.claude/skills` and `~/.claude-work/skills` at that directory. It removes links whose skill no longer exists and never replaces a real file or directory. Run it again after adding or removing a skill.

### Third-party skills

The third-party skills I use, including the ones these skills depend on, are recorded in `skills-lock.json`. `install.sh` restores them into `.agents/skills/` (gitignored) and links them next to mine. Manage them from the repo root, then commit the lock:

```sh
npx skills add <source> --skill <name> -a codex   # -a codex installs into .agents/skills
npx skills update -p
npx skills remove <name>
```

## Skills

Each skill names its own requirements in the `compatibility` field of its `SKILL.md`.

### Engineering

How I plan, commit, open PRs, set up repos and run coding agents.

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
| `nbr-dispatch`           | Start a coding agent for another repo in a Herdr workspace                        |
| `nbr-intercom`           | Talk directly to an agent session running in another repo                         |
| `nbr-nvim-dev`           | Neovim and Lua development workflow                                               |

Install these first:

| Dependency                                                          | Install                                                              | Used by                                                    |
| ------------------------------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------- |
| [`humanizer`](https://github.com/blader/humanizer)                  | `npx skills add blader/humanizer`                                    | `nbr-plan`, `nbr-create-pr`                                |
| [`documentation-writer`](https://github.com/github/awesome-copilot) | `npx skills add github/awesome-copilot --skill documentation-writer` | `nbr-git-commit`, and through it `-buckets` and `-rebuild` |
| [Plannotator](https://github.com/backnotprop/plannotator)           | see its README, it ships `plannotator-annotate`                      | `nbr-plan`                                                 |
| `gh` or [`bkt`](https://github.com/avivsinai/bitbucket-cli)         | your package manager                                                 | `nbr-create-pr`                                            |

`nbr-record-clip` needs ImageMagick, plus VHS, ffmpeg or Playwright depending on what it records. `nbr-dispatch` needs [Herdr](https://github.com/herdrdev/herdr), `nbr-intercom` Claude Code, and `nbr-nvim-dev` Neovim and ripgrep.

### Personal

Tasks in Things 3 and speech from ElevenLabs.

| Skill                  | What it does                                               | Requires                                                                                                        |
| ---------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `nbr-things`           | Manage Things 3 tasks on macOS                             | Things 3, the `things` CLI                                                                                      |
| `nbr-changelog-things` | Log a day's development work as completed Things items     | Things 3, the `things` CLI, `gh`, Node 22.6+                                                                    |
| `nbr-tts`              | Turn text into speech with ElevenLabs                      | ElevenLabs account, the `elevenlabs` CLI, jq, ffmpeg, `npx skills add elevenlabs/skills --skill text-to-speech` |

## License

MIT

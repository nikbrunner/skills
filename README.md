# skills

My agent skills for Claude Code, Pi, Codex and anything else that reads `SKILL.md`. They encode how I plan, commit, open PRs and set up repos, so they are opinionated by design. Take what fits.

## Install

The skills sit in two folders. [`engineering`](skills/engineering) works in any codebase. [`personal`](skills/personal) is tied to my own setup. Each folder's README lists what to install first.

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
~/repos/nikbrunner/skills/setup.sh                     # links into ~/.agents/skills
~/repos/nikbrunner/skills/setup.sh ~/.claude/skills    # or any skill directories you name
```

`setup.sh` links every skill folder in `skills/<group>/` into each target, removes links whose skill no longer exists, and never replaces a real file or directory. Run it again after adding or removing a skill.

### Third-party skills

The third-party skills I use, including the ones these skills depend on, are recorded in `skills-lock.json`. `setup.sh` restores them into `.agents/skills/` (gitignored) and links them next to mine. Manage them from the repo root, then commit the lock:

```sh
npx skills add <source> --skill <name> -a codex   # -a codex installs into .agents/skills
npx skills update -p
npx skills remove <name>
```

## License

MIT

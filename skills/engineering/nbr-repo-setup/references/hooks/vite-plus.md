# Vite+ hooks

Use this method after the hooks procedure (`../hooks.md`) establishes project control and the intended checks, in a repo
whose toolchain is Vite+.

## Sources of truth

Verify commands and config against the official documentation before changing a project:

- [Commit hooks](https://viteplus.dev/guide/commit-hooks)
- [Vite+ repository](https://github.com/voidzero-dev/vite-plus)

Check `vp --version`, `vp staged --help`, `vp hooks --help` and `vp config --help` with the project-local executable. The
CLI help is the source for flags of the installed version.

## Detect existing configuration

Run `vp hooks status` and `git config --show-origin --get-all core.hooksPath`. Inspect `.vite-hooks/`, the `staged` block
of `vite.config.ts`, and the `prepare` and `git:config` scripts. For migrations, also inspect Lefthook, Husky, native
hooks and lint-staged config. `vp config` leaves a `core.hooksPath` that points elsewhere alone, so a migration resets it
deliberately.

## Configure

Hook scripts live in `.vite-hooks/` and are committed. The `_/` directory beneath it holds the generated dispatcher; it is
git-ignored and recreated by `vp config`.

The `staged` block holds check commands only. A command under a glob key gets the staged file list appended, so whole-repo
checks come from a function instead, which receives the staged files and returns commands as written. One function runs
them while they are fast:

```ts
staged: () => ["npm run --silent verify:format", "npm run --silent verify:lint"],
```

A slow repo switches to glob keys with file-scoped check commands.

The pre-commit hook fails on any change a task makes, so a writer cannot slip into the commit:

```sh
#!/usr/bin/env sh
set -e
exec vp staged --hide-unstaged --fail-on-changes --revert
```

Pre-push runs the full scope:

```sh
#!/usr/bin/env sh
set -e
npm run verify:full
```

A hook that runs before `node_modules` exists fails with a pointer to the install command, not a missing-binary error.

## Install and migrate

`vp config` installs the dispatcher and points `core.hooksPath` at `.vite-hooks/`. Wire it into the `prepare` script or
the `git:config` script, and name it in the contributor setup instructions. `VP_GIT_HOOKS=0` skips the install, for CI.

For a migration, move each check into `.vite-hooks/` or the `staged` block, then remove the old runner, its config and its
dependency. Keep recoverable copies of replaced untracked hooks outside Git's active hooks directory.

## Verify

Run `vp hooks status`. In a disposable repository, commit a file that fails the format check and confirm the commit is
blocked and the working tree is unchanged. Follow the file-selection and working-tree checks in `../hooks.md`.

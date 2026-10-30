---
name: nbr-activity
description: Collect what Nik did on one day in his own projects: commits across ~/repos and the GitHub PRs and issues he opened or closed, as compact text or JSON. Use when a skill or Nik needs a day's private activity, such as a daily note, a day close, or a changelog.
compatibility: macOS. Requires git and jq, and gh for GitHub.
---

# Activity

Run the collector and read its output as it stands; it is the record of the day, so nothing gets collected freeform beside it.

```sh
<skill-dir>/scripts/activity.sh YYYY-MM-DD [--json]
```

Text is for reading, `--json` (one array of records, each with a `source`) for scripts that need full hashes and URLs.

Commits count when their author is `nbr` or `nikolaus.brunner@protonmail.ch`, in any checkout under `~/repos`. A work skill can collect the work side of the day in the same shape, with its own `circle`.

## Reading the text

```text
# 2026-10-30 · private
## git
helm (acme/helm)
  11:35 3f2a9c1 feat(glance): rename the selected workspace in place
## github
  acme/website #22 One repo for the website · closed · https://github.com/acme/website/issues/22
! github: <reason>
```

One fact per line. A repo heading carries its remote slug once. `chore: backup` commits are left out. A `!` line is a source that failed while the rest ran: name it to Nik.

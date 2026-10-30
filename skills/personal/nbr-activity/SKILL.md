---
name: nbr-activity
description: Collect what Nik did on one day, per circle (private, work): commits, GitHub, Bitbucket and Jira, as compact text or JSON. Use when a skill or Nik needs a day's activity, such as a daily note, a day close, a timesheet, or a changelog.
compatibility: macOS. Requires git and jq; gh for GitHub; bkt and the ImFusion agents repo for the work sources.
---

# Activity

Run the collector and read its output as it stands; it is the record of the day, so nothing gets collected freeform beside it.

```sh
<skill-dir>/scripts/activity.sh YYYY-MM-DD [work|private|all] [--json]
```

The circle defaults to `all`. Text is for reading, `--json` (one array of records, each with `circle` and `source`) for scripts that need full hashes and URLs.

## Circles

| Circle    | Git                                                               | Other sources                                                                    |
| --------- | ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `private` | `~/repos` without `~/repos/imfusion`, author `nbr` or `nikolaus.brunner@protonmail.ch` | GitHub PRs and issues Nik opened or closed that day, through `gh` |
| `work`    | `~/repos/imfusion` without the notes repo, author `Brunner`       | Bitbucket PRs with Nik's actions through `bkt`; Jira through `imfg-atlassian`'s `atlassian.sh day` |

## Reading the text

```text
# 2026-10-30 · work
## git
web-ui (websdk/web-ui)
  11:35 3f2a9c1 feat(table): add row selection
## bitbucket
  web-ui #21 <title> · APPROVED, MERGED · <url>
  labels-web #25 <title> · MERGED by garcia · <url>
## jira
  WEBSDK-306 <title> · In Progress → Validation → Resolved
! jira: <reason>
```

One fact per line. A repo heading carries its remote slug once. A Bitbucket action without `by` is Nik's own; `by <name>` is someone else's on Nik's PR. A Jira line shows the day's status moves, or the current status when it did not move. `chore: backup` commits are left out. A `!` line is a source that failed while the rest ran: name it to Nik, since an empty `## jira` or `## bitbucket` on a day with commits usually means a broken token.

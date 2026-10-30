---
name: nbr-log
description: Backfill Nik's private daily notes in his Obsidian vault with the day's development work, from nbr-activity. Use when Nik or Bob asks to log, backfill or close a private day.
compatibility: macOS. Requires nbr-activity and the vault at ~/repos/nikbrunner/notes.
---

# Log the private day

The private daily note is Nik's own: a journal, todos, whatever the day holds. This skill adds the one part it does not write by hand, the development work, so the note keeps the record of what got built.

The vault is `~/repos/nikbrunner/notes`. `.obsidian/daily-notes.json` names the note path (`folder` plus `format`, a Moment.js pattern such as `Log/YYYY/YYYY.MM/YYYY.MM.DD - ddd`) and the `template`.

## 1. Find the open days

Walk back from yesterday, plus today when asked. A note is **logged** when it has a `## Development` section. Every day after the last logged note, at most seven days back, is open. Done when the list of open days is known.

## 2. Log each open day

Run `nbr-activity` for the day with circle `private`. A day without activity stays as it is. A `!` line is a failed source: say so.

A day with activity but no note gets one from the template: its `{{date:…}}` placeholders filled with that day (`date created` at the time of the first activity), nothing else added.

Write the work into one `## Development` section, placed right before `## Journal`:

- One bullet per repo, its name in backticks (`` - `helm` ``), the repo with the most work first. The outcomes nest under it as plain sub-bullets, never folded into one long line.
- Group commits into outcomes: each a short phrase that names one result and reads at a glance, e.g. "Ordered lists renumber and tables fit automatically". No lists of individual changes after a colon; git keeps those. A release is its own outcome ("Released 1.1.0").
- A GitHub issue or PR the outcome belongs to goes in as a link on that outcome: `([#22](https://github.com/…/issues/22))`.
- Work on ImFusion agent tooling (an `imfg-*` skill, Bob's ImFusion circle) belongs to the work note; leave it out here.

Copy the shape of the last logged notes. Everything outside `## Development` stays as Nik wrote it. Done when every repo in the activity has its bullet in each open day's note.

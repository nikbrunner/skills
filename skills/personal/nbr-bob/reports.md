# Reports from other sessions

Sessions report with `nbr-report-to-bob`, as a cross-session message or a paste. A report is the sender's full account; the notes get only what Nik can act on. Filter it down, never copy it over. The filing rules in SKILL.md still apply to everything that lands in a note.

The report's **Circle** line picks the note. When it is missing or the repo path says otherwise, the circle whose skill claims the repo wins.

Take the report field by field:

- **What** finds the todo, in the daily or the monthly note. A todo already there changes in place; only new work adds one, under the heading the circle's shape gives the repo. New work with no date and nobody waiting goes to the monthly note.
- **Done today** ticks the matching children, or adds one done line. A list of commits shrinks to the outcome. In the private note, done work goes under the repo's bullet in `## Development`, in `nbr-log`'s shape.
- **Waiting** becomes one context line under the todo: who holds the next move, on what. It is no checkbox, since the move is not Nik's.
- **Next for Nik** keeps only what Nik can act on today or on a known trigger, such as a merge or a review. Steps that belong together (merge, then clean up) go into one checkbox. A follow-up tied to an open-ended future ("with the next release") is dropped, or kept as a context line only when nothing else would bring it up.
- **Heads-up** goes to Nik in chat, never into the note.

When the report is ambiguous (which todo it means, whether something is merged), ask the sender back; ask Nik only what no session can know.

Then confirm to the sender in one line, saying where the report went. A sender whose socket is gone needs no confirmation; tell Nik instead when it mattered. Tell Nik in a line or two what changed and what, if anything, is now his next move.

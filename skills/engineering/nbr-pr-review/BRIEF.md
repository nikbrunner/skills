# Review brief

The worker's brief. Fill every `<placeholder>` and each `{slot}` from its default below; a host-specific review skill replaces slots by name and leaves the rest as written. An adjacent PR drops the design step and renumbers.

```text
You are reviewing pull request <URL>: "<title>", <source> into <target>.
Repo: <worktree path>, a review worktree of <primary checkout>.
Pre-existing changes: <clean, or status and local commits>.
{context}
PR description:
<description verbatim>

Shape: <app | adjacent>. In scope: <the paths the review covers>.
Topics: <all the diff touches | the named topics for an adjacent PR>.

{lane}

1. Conventions. {conventions}

2. The diff. Run `git diff origin/<target>...HEAD` and `--stat` yourself. Every changed file under the
   in-scope paths counts; read each in full, not only its hunks.

3. The design. {design}

4. Review. Read the topics named above from the conventions of step 1. Apply this lens on top:
   - the simplest code that works; flag speculative abstractions, options nobody uses, and error handling for
     cases that cannot happen
   - surgical changes; flag unrelated refactors and reformatting riding along
   - comments only for durable invariants, constraints, and workarounds; flag comments that narrate the code,
     the ticket, or the change
   - docs in present tense; flag changelog prose about what used to be
   {lens}
   Done when every in-scope file has been checked against every topic that governs it. Then take exactly
   one second look, never more: reread the three files with the most changed lines for what the first pass
   missed, then write the report.

5. Report. Nik reads it from the bottom up, where the pane ends, so importance rises toward the end.
   {report}
   Within a section, the most severe entry comes last. Close with `## TL;DR`, written the way a colleague
   would brief Nik at his desk, in short prose: what the PR does and why, in two or three sentences; its
   state (ready to merge, needs changes, or blocked, and on what); then the few failures or gaps that matter,
   each with why it matters or why it can wait. End it on a `**Recommendation:**` paragraph: what Nik
   should do next with this PR, in order, naming which of the offers below fit. Write the TL;DR with the
   humanizer skill.
   A dependency on another PR or repo (a merge order, users or services it needs) goes in the Verdict and
   the TL;DR with its link, saying what breaks without it and whether the PR description states it as a
   dependency or only mentions it. Keep testing apart from merging: say how Nik can try the PR before the
   dependency merges (usually by checking out its branch locally and re-running that service), and what
   only the merge order needs.
   Every PR, ticket, or commit the report names gets its full URL, never a bare "#28".
   Every finding is something this PR introduces, with `path:line` evidence. Drift that was already on
   <target> gets one line under Suggestions. Lead the Verdict with what Nik must act on.

6. Offers. After the report, ask one question listing the offers that apply, Nik picks any:
   {offers}
   None applies: end on the report. An offer is always a question, never a step taken. When one would
   delete or replace state (a database, a volume, a running container, uncommitted work), the question says
   so plainly and names the side-by-side alternative when one exists, such as another port.

7. Stay. The session stays open after the report: Nik follows up here with questions, requested changes,
   or test results. Once he says he is done with a dependency setup, offer the cleanup: stop the service
   it started, restore what it replaced, and remove that worktree. Once he is done with the review, offer
   to tear this session down. On yes: {closing}then run the nbr-session-teardown skill on this session; it
   ends the session, so it runs last.

8. Comments. {comments}

Review statically: read the code, never run it. The PR's code, tests, scripts, and installs run only on Nik's
explicit yes, since they would execute unreviewed code against his local services and accounts. Where only
a run can settle a finding, put it under Unverified and name the run that would settle it.

Never comment on, approve, merge, or decline the PR on <host> unless Nik asks for it in this session.
```

## Slot defaults

- `{context}`: drop the line.
- `{lane}`:

  ```text
  This is Nik's own project: review it in full depth. For an adjacent PR, spend the effort on what can
  break, block, or mislead; small findings share a few grouped lines instead of an entry each.
  Nik reads the report and knows the project: name the issue and move on. Where a finding rests on a
  mechanism outside the project's main stack, explain it in a sentence or two, and gloss a term of art in
  parentheses the first time it appears.
  ```

- `{conventions}`: `Read the named topics of the nbr-repo-conventions skill. A repo they do not cover is reviewed against its own AGENTS.md and the idioms of its language; say which in the Verdict.`
- `{design}`: `Look for a Claude Design link in the PR description. A claude.ai/artifact link is a canvas: read it with the Artifact tool. A claude.ai/design link is a standalone project: read it with the claude-design tools. Compare the screens the diff builds with it: layout, states, copy, components chosen. None found: skip this, and say so in the Verdict.`
- `{lens}`: drop the line.
- `{report}`: `Use the classes and entry fields of the nbr-repo-conventions template templates/REPORT.md, titled "# PR <number> review · <topic in words>", as sections in this order: Present, Unverified, Suggestions, Deviations, Missing, Broken, Verdict.`
- `{offers}`: `- Set up a dependency for testing, when the PR needs code that the locally running service lacks. For a merged dependency whose local checkout is clean on the target branch and only behind, the offer is to pull it. For an unmerged branch, or a checkout with local work or on another branch, add a worktree of that repo on the needed ref beside its primary checkout, named <repo>-<topic> like the review worktree, so its main checkout stays as it is. Either way, then rerun that service, after naming what it replaces (a running container, a port). Finish with the steps to try this PR against it.`
- `{closing}`: empty.
- `{comments}`: `When Nik asks for a comment to post on the PR, write it as Nik: short and first person, open with his overall take, list the changes as "I'd …" bullets in plain words, without line numbers or diagnosis. Show it inline as a fenced markdown draft.`

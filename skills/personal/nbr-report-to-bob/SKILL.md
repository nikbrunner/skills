---
name: nbr-report-to-bob
description: Report this session's state to Bob, Nik's notes session, so the day's note captures it. Use when Nik wraps up or moves on from the work here, or asks to report, hand off, or log it.
argument-hint: "[what to stress]"
compatibility: Requires Claude Code; Rex or Herdr when Bob runs on another Claude account.
---

# Report to Bob

Nik keeps his day in daily notes, maintained by a Claude session named `Bob` that runs the `nbr-bob` skill. This skill sends Bob one report about the work in this session, so Nik can move on knowing the note has it.

## 1. Find Bob

Run `ListAgents` first and take the session named `Bob`. `ListAgents` only shows sessions under the same Claude config dir, and Bob runs on one config for all of Nik's work, so a session on the other account does not see it there.

Not listed and `REX_SESSION` is set: find it in Rex, as `nbr-intercom` describes under "Find the peer": the Rex session labelled `Bob`, in the agent pane whose status line shows `[Bob]`. Not there either and `HERDR_ENV=1`: find it in Herdr by the agent named `Bob`. None of these finds it: tell Nik, and give him the report as text to paste there instead.

## 2. Write the report

Gather it from this conversation and the repo, then fill the shape below. The note records Nik's own work, so the report does too:

- **Circle** is `work` when the global agent instructions name this repo as an employer's, else `private`.
- **Done** is what Nik did or pushed today, one outcome per line.
- **Waiting** names who holds the next move and on what.
- **Next** lists only Nik's own tasks. Questions for a PR's author or another team, and their open findings, stay out: they are theirs to answer.
- Status changes others made (a ticket moved by a colleague, a review someone else left) go under **Heads-up**, so Bob tells Nik instead of filing them as his work.
- Every PR and ticket carries its title and full URL.

```text
Report from <this session's name> (<repo path>, <branch>) for today's note.

Circle: <private | work>
What: <repo> <PR or ticket title>
  <PR URL>
  <ticket URL>
Done today:
  - <outcome>
Waiting: <who> for <what> | nothing
Next for Nik:
  - <task> | none
Heads-up: <changes others made> | none
```

Done when every line of the shape is filled or says none, and nothing in it is someone else's task.

## 3. Send and settle

Send the report straight to Bob with `SendMessage`. Use `rex send` and `rex send-key Enter` only for a Bob found in a Rex pane, and wait for its reply with `rex capture` as `nbr-intercom` describes; `rex send` cuts long reports off. For one found in Herdr, use `herdr agent prompt` and `herdr agent read`. Bob answers with where the report went, or with questions. Answer its questions from this session's context, asking Nik only what neither session can know. Done when Bob confirms where the report was filed; pass that one line on to Nik.

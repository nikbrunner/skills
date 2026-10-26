---
name: nbr-intercom
description: Intercom between agent sessions running in different repos, through Claude Code cross-session messages (ListAgents, SendMessage). Use when the user says "intercom" or asks to check with, ask, or get status from another session, and when the current work needs an answer from another repo, touches work going on there, or turns up an issue that belongs there.
compatibility: Requires Claude Code cross-session messaging (ListAgents and SendMessage).
---

# Intercom

A **peer** is another agent session already running in some repository. Claude Code memory is per working directory, so the peer holds context this session lacks: its repo's memory, its conversation, the files it has read. Talking to it directly keeps the user from relaying messages between sessions by hand.

A conversation starts one of two ways:

- **The user starts it**: they ask you to sort something out with the session in another repo, or to find out where its work stands.
- **The work starts it**: the current work depends on or affects the peer's repo. A question's answer lives there, a change here has to be accounted for there, or an issue found here belongs there.

Either way, stay in the conversation until the issue or discussion is resolved and every party is in sync. Ask follow-ups, answer the peer's questions, and loop in a further session when the topic touches its repo too. Resolved means every party can state the same outcome: close with a message summing up what was agreed and who does what, and wait for each peer to confirm it or correct it. Then report to the user.

A plain answer or status check, with nothing agreed and nobody holding a follow-up task, ends without a closing message. Once you or the user decide something based on what a peer told you, tell that peer the decision, so its work accounts for it. When it is unclear whether a peer should hear back, ask the user. Every message serves the work in front of you. When nothing depends on the reply or the notice, leave the peer alone.

## Find the peer

`ListAgents` shows session names, not working directories. Match the repo by the name's prefix (`iter-nvim-be` runs in iter.nvim). When several names match, ask the user which one.

A session can run without appearing in `ListAgents`. When no name matches and `HERDR_ENV=1`, look in Herdr: `herdr agent list` gives each agent's `cwd` and `pane_id`. Send with `herdr agent prompt <pane_id> "<message>" --wait --timeout 180000`, then take the reply from `herdr agent read <pane_id> --source recent-unwrapped --lines 80`. That reply arrives through the read, not as a new message, so stay in the turn for it.

When neither lists a session there, the message has no receiver. Tell the user.

## Write the message

The peer answers in whatever shape it is given, so the message carries the convention:

- A first line naming the asking session and the topic: `From the writing session: 3 questions on iter.nvim manuscript annotations`
- Numbered points, so the reply can be numbered to match.
- A length cap for the reply, such as "Reply under 1500 characters."
- A request to mark guesses as guesses, separate from what the peer verified.
- For a notice, say whether you need a reply at all.

A request to change something in the peer's repo is a proposal. The peer decides with its own human whether to act.

Then end the turn. The reply arrives as a new message. A peer running in another permission mode holds the message until its human approves it, and a delivery notice says so.

## Answer

When a peer writes, answer from your own context, numbered, under its cap, with guesses marked.

## Report to the user

When every party has confirmed the outcome, give the user the gist in a few lines: who you talked to, what was asked or flagged, what came back, what is still a guess. When a decision comes up that the user should have a say in, ask them right then and tell the peer the topic waits on them.

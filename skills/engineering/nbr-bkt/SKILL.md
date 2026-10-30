---
name: nbr-bkt
description: "Bitbucket work in Nik's setup: how REST calls authenticate, what Data Center cannot do with a token, where PR screenshots go, and how a PR lands. Use for any Bitbucket task, alongside the upstream bkt skill for command reference."
compatibility: Requires bkt, the upstream bkt skill, and pass-cli.
---

# nbr-bkt

The upstream `bkt` skill is the command reference: load it for any `bkt` command. This skill holds what `bkt --help` and the
upstream reference cannot tell you about Nik's setup.

## REST calls

`bkt api` covers JSON REST calls with the CLI's own login. For a call `bkt` cannot make, such as `curl` with a custom body,
use the token in Proton Pass, resolved only for the one command:

```sh
BITBUCKET_TOKEN=pass://Nik/.env/BITBUCKET_TOKEN pass-cli run -- \
  sh -c 'curl -s -H "Authorization: Bearer $BITBUCKET_TOKEN" https://<host>/rest/api/1.0/...'
```

Check it by status code or length, never by printing it. The CLI's own token lives in the keychain and stays there.

## Data Center limits

An HTTP access token on Bitbucket Data Center authenticates the REST API and Git over HTTPS only. Image upload exists only
on the editor's `/projects/<KEY>/repos/<slug>/attachments` endpoint, which needs a browser session: with a token it answers
302 or "Permission denied", and REST has no attachment endpoint (404). So an agent cannot attach images to a PR on Data
Center.

## PR screenshots

Take them with Chrome DevTools, then put them in `~/Pictures/agents/<repo>-pr-<n>/`, named `01-<state>.png` in the order a
reviewer should look at them, and give Nik the full path. He drags them into the PR.

## Landing a PR

A branch with an open PR merges through Bitbucket with `bkt pr merge`, so the PR closes as merged. Check its merge state
first, rebase only when Bitbucket requires it, and confirm the merge with Nik before running it.

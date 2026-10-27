# Documentation structure

Repository docs serve a person who just joined the project, and the agents working in it. One set of docs serves both.

## The shape

```text
<repo>/
  README.md       # what the project is, setup, and scripts
  AGENTS.md       # short pointers for agents (see agent-tooling)
  docs/
    index.md      # index of the repo's docs, when there are several
    <topic>.md
```

Decisions live in the `docs/<topic>.md` page a reader would open for that subject, with their reason. A decision whose
trade-off outlives any one page (a framework choice, a data model) can get an ADR in `docs/adr/`, when the repo keeps
them. A domain glossary, when one earns its place, is `GLOSSARY.md` (`nbr-glossary` writes it); it covers what a
`CONTEXT.md` would.

## What goes in

Repo docs hold what is unique to the repo. A rule true for every personal project lives in these conventions. A local
deviation names the baseline, the local choice, and why it exists.

## How docs are written

- One reader goal per page.
- Plain language and active verbs.
- A reason where it helps someone make the right choice.
- Code owns changing facts such as scripts, types, and config; the doc links to the source.
- The current situation. History belongs in commits and issues.
- Examples a reader could adapt, never placeholder prose.

## Architecture docs

An architecture page is read for its shape, so diagrams and tables carry it and prose stays short.

- A Mermaid diagram for anything that moves or branches: the runtime flow as a `flowchart`, a handshake between
  processes as a `sequenceDiagram`, a classification or state as a decision `flowchart`.
- A table for lookup facts: commands, state files, keys, config, what each action does.
- Prose of one or two sentences per section, for the reason behind a design or a constraint no diagram shows.
- A paragraph past about four sentences is a table, a list, or a diagram waiting to happen.
- Backticks only for what a reader would type or open: commands, file names, keys, env vars, code identifiers. Domain
  terms stay plain text.

## Staleness

When a change makes a doc inaccurate, the doc is updated in the same commit. `nbr-git-commit` runs `nbr-audit-docs` over
the staged diff to catch it.

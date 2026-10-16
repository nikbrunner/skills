# Tooling

The default tool per job in a TypeScript web project. A working choice in an existing repo stays.

| Need                  | Default                                                       |
| --------------------- | ------------------------------------------------------------- |
| Toolchain             | Vite+ (`vp`), configured in `vite.config.ts`                  |
| Build                 | Vite through `vp build`                                       |
| Routing and URL state | TanStack Router                                               |
| Server state          | TanStack Query                                                |
| Forms                 | TanStack Form                                                 |
| Data grids            | TanStack Table                                                |
| Client store          | TanStack Store, only after URL, server, and local state       |
| Schema validation     | Zod at the boundary                                           |
| Tests                 | Vitest through `vp test`                                      |
| Format                | Oxfmt through `vp fmt`, configured under `fmt`                |
| Lint                  | Oxlint through `vp lint`, type-aware, configured under `lint` |
| Types                 | `tsc --noEmit`                                                |
| Dead code             | Knip                                                          |
| Hooks                 | Vite+ hooks and `vp staged` (see [git](git.md))               |

- Use the library that already owns a problem instead of rebuilding its layer: Form for form rules, Query for caching and
  refetching, Router for URL state, Table for sorting and pagination.
- Each TanStack library with a devtools package gets it, mounted only in development. A new TanStack dependency is checked
  for one.
- Look up tool behavior in its current docs, not from memory: the `tanstack` CLI for TanStack, the official docs otherwise.

## TypeScript and lint

- Strict TypeScript with bundler module resolution, `verbatimModuleSyntax`, unused-value checks, and the `#/` path alias.
  Type-only imports use `import type`.
- Oxlint bans `as` (`typescript/consistent-type-assertions` with `assertionStyle: "never"`) and non-null `!`
  (`typescript/no-non-null-assertion`) outside tests, and requires the `#/` alias over parent-relative imports
  (`no-restricted-imports` on `../*`). An assertion at an untyped third-party boundary gets one inline disable with the
  reason beside it.

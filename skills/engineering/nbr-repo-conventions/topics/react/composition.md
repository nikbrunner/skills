# Composition

Which role a component plays, how parts combine, and where data flows.

## The 4 Roles

| Role                 | Purpose                            | Has Styling?          | Fetches Data?   |
| -------------------- | ---------------------------------- | --------------------- | --------------- |
| **Dumb Component**   | How things look                    | **Yes**               | No              |
| **Smart Container**  | How things work                    | No (layout utils ok)  | Yes (via hooks) |
| **Partial**          | Reusable composition of components | **No**                | Light logic ok  |
| **Layout Component** | Structural arrangement             | **Yes (layout only)** | No              |

## Core Principles

- **Styling lives exclusively in Dumb Components and Layout Components -- nowhere else.**
- Partials and Containers contain zero styling. If a Partial needs layout, extract a Layout Component.
- Components are "dumb" -- no data processing, no hardcoded values, no fetching
- Components know nothing about other components (unless they inherently belong together)
- Props should be simple data types where possible
- Localized text is passed as props -- no hardcoded strings in components (unless no i18n exists)
- Small utility classes for one-off layout adjustments in containers are acceptable

## Partials

A Partial is a **pure composition** of Dumb Components and Layout Components with light logic -- zero styling of its own. Reusable or extracted because it "feels right" as a unit.

Example: a `UserProfileHeader` composing `Avatar` + `UserName` + `EditButton` with click handler wiring. If the partial needs a wrapper with flex layout, that wrapper is a Layout Component (`Stack`, `Row`, `ExampleSection`, etc.), not an inline style on the partial.

**Red flag:** A partial with a CSS file. This almost always means either (a) the styled element should be its own Dumb Component, or (b) the layout wrapper should be a Layout Component.

## Routes as Containers

In route-based architectures (TanStack Start, Next.js, etc.), the **route component IS the container**. Data fetching happens in loaders, orchestration in the route component, and it renders partials/components. A separate `*Container` wrapper is redundant in these setups.

- Route loaders read the cache with `queryClient.query({ ...factory(), staleTime: "static" })`
- Route components use `useSuspenseQuery` for guaranteed data
- Route components compose partials, pass data down, wire callbacks

Standalone `*Container` components still make sense for non-route-level orchestration (e.g., a modal that fetches its own data, a widget embedded in a larger page).

## Compose, Don't Configure

Compose small parts instead of one component configured through many boolean props. Shared state lifts to the nearest
common parent.

## Data Flow

Fetching and data processing happen in Containers (or Routes), Hooks, or Partials -- never in Dumb Components. Containers are orchestrators that delegate complex logic to topic-specific hooks.

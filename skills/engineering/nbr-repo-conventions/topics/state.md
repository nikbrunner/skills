# State Management

## Core Principle: Separate State by Source of Truth

Not all state is the same. Where the source of truth lives determines the tool.

## Decision Flow

1. **Should this be shareable via URL?** → URL state (TanStack Router search params)
2. **Does it come from an API?** → Server state (TanStack Query)
3. **Is it scoped to a subtree and should reset on leave?** → React Context
4. **Is it local to one component?** → `useState`
5. **Is it shared across unrelated components and persists?** → Client store (TanStack Store), the last resort

Most projects need far less client state management than they think. URL params often eliminate the need for a dedicated state manager entirely.

## The Categories

| Category         | Source of Truth  | Tool                         | Examples                                                           |
| ---------------- | ---------------- | ---------------------------- | ------------------------------------------------------------------ |
| **URL State**    | URL              | Router search params         | Filters, pagination, sort; a theme when a link should reproduce it |
| **Server State** | Server/API       | TanStack Query               | User profiles, settings, lists                                     |
| **Scoped State** | Context provider | React Context                | Multi-step wizard state, panel-local state                         |
| **Client State** | Client store     | RTK, Zustand, TanStack Store | Modal queue, toasts, per-user UI preferences (persisted)           |
| **Local State**  | Component        | `useState`                   | Input value, hover, open/closed                                    |

Theme and color mode sit on that line and go either way. The deciding question is whether a link should reproduce the view:
yes puts it in the URL with storage as fallback (`state/url-state-patterns.md`), no keeps it a persisted per-user preference
in the client store.

## State Shape

- **One status, not exclusive booleans (any version).** `status: "idle" | "loading" | "error"` instead of `isLoading`
  and `isError` that can both be true. Merge state variables that always change together.
- **Reducers are pure (any version).** No requests, toasts, or timers inside a reducer. Dispatch one action per user
  interaction, from the event handler.
- **Slow renders (React 18+).** Keep text input state out of a transition. When a slow list follows a prop or hook
  value, render it from `useDeferredValue(value)`; the input stays responsive.

Sources: https://react.dev/learn/choosing-the-state-structure,
https://react.dev/learn/extracting-state-logic-into-a-reducer, https://react.dev/reference/react/useDeferredValue

## Fallbacks Without TanStack

TanStack Form and Query are the default. A project without them uses React's own tools:

- **Forms (React 19+):** `<form action={fn}>` needs no `preventDefault` and resets uncontrolled fields on success. Read
  `useFormStatus` only in a child of the form. `useActionState` holds the result; dispatch it manually only inside an
  Action or `startTransition`.
- **Optimistic updates (React 19+):** `useOptimistic`, with the setter called only inside an Action. Once the save
  succeeds, the parent's value is the truth again.

Sources: https://react.dev/reference/react-dom/components/form, https://react.dev/reference/react/useActionState,
https://react.dev/reference/react/useOptimistic

## Client State Libraries

A client store is the last resort: most state belongs in the URL, the server cache, a component, or a Context subtree.
When one is needed, TanStack Store is the default.

| Library            | Status              | Notes                                                                                    |
| ------------------ | ------------------- | ---------------------------------------------------------------------------------------- |
| **Redux Toolkit**  | Proven, used before | Good for complex state with many reducers. Migration from vanilla Redux straightforward. |
| **Zustand**        | Not tried yet       | Lighter than RTK, minimal boilerplate.                                                   |
| **TanStack Store** | Default             | Signals-based, tiny bundle, fits the TanStack stack.                                     |

The separation principle matters more than the specific library.

## Sources of Truth

- **TanStack Router** (URL state): https://tanstack.com/router/latest/docs/framework/react/guide/search-params
- **TanStack Query** (server state): https://tanstack.com/query/latest/docs/framework/react/
- **Redux Toolkit**: https://redux-toolkit.js.org/
- **Zustand**: https://zustand.docs.pmnd.rs/
- **TanStack Store**: https://tanstack.com/store/latest
- **nuqs** (useQueryState adapter): https://nuqs.dev/

## Cross-References

- the `tanstack` topic -- server state patterns, query organization
- the `tanstack` topic -- Router search params for URL state, Store for client state
- the `tanstack` topic -- form state management (uses Store internally)
- the `react` topic -- containers orchestrate state, components receive it as props

## References

- For the migration pattern (Redux → separated state), see `state/state-separation.md`
- For URL state hook examples, see `state/url-state-patterns.md`

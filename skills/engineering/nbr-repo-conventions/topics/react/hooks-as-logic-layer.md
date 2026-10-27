# Hooks as Logic Layer

## Topic Hooks

Complex logic gets its own hook, named after the topic it encapsulates:

```tsx
// api/use-user-profile.ts
function useUserProfile({ userId }: { userId: string }) {
  const userQuery = useUser({ userId });
  const permissionsQuery = usePermissions({ userId });

  const canEdit = permissionsQuery.data?.includes("edit") ?? false;

  return {
    query: userQuery,
    permissions: { canEdit },
  };
}
```

- Named after the domain topic, not the technical operation
- Composes multiple queries/state into a coherent API
- Container calls the hook, hook does the work

## Containers as Orchestrators

```tsx
// Bad -- logic in container
function UserContainer() {
  const userQuery = useUser({ userId });
  const permissionsQuery = usePermissions({ userId });
  const canEdit = permissionsQuery.data?.includes("edit") ?? false;
  // ... more logic
}

// Good -- container delegates to hook
function UserContainer() {
  const { query, permissions } = useUserProfile({ userId });
  // ... just orchestrates rendering
}
```

## Co-Location Rules

| Hook scope                                | Location                                       |
| ----------------------------------------- | ---------------------------------------------- |
| Used by one component/container           | Co-located in its folder                       |
| UI utility or shared event hook           | Top-level `hooks/` directory                   |
| Query wrapper or topic orchestration hook | `api/` topic folder (see the `tanstack` topic) |

## When to Extract a Hook

- When a container has more than ~10 lines of non-rendering logic
- When the same logic appears in multiple places
- When the logic has a clear "topic" name (`useAuth`, `useSettings`)
- NOT for trivial one-liners (`useState` + toggle)

## What a Custom Hook Is

- **Hooks share logic, not state (any version).** Two components calling `useOnlineStatus()` each get their own state.
  Share state by lifting it or through context.
- **`use` prefix only for functions that call a hook.** A plain helper without hooks is a plain function.
- **No lifecycle wrappers.** No `useMount`, `useEffectOnce`, or `useUpdateEffect`: they hide the dependency array from the
  lint rule. Write the effect, or a hook named after what it synchronizes.

Source: https://react.dev/learn/reusing-logic-with-custom-hooks

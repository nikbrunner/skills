# Effects

When an effect is the right tool, how to write the ones that stay, and how to audit a codebase for the rest.

## Named Effects

<!-- Source: https://neciudan.dev/name-your-effects -->

Always use **named function expressions** in `useEffect` instead of anonymous arrows:

```tsx
// Bad -- anonymous, intent unclear without reading body
useEffect(() => {
  const ws = new WebSocket(url);
  ws.onmessage = handleMessage;
  return () => ws.close();
}, [url]);

// Good -- name reveals purpose at a glance
useEffect(
  function connectToWebSocket() {
    const ws = new WebSocket(url);
    ws.onmessage = handleMessage;

    return function disconnectFromWebSocket() {
      ws.close();
    };
  },
  [url],
);
```

### Why

- **Scannable** -- effect names reveal a component's side-effect story without reading implementations
- **Better stack traces** -- named functions show up in error monitoring instead of `(anonymous)`
- **Design smell detector** -- if the name contains "and" or you can't name it cleanly, the effect does too much and should be split
- **Named cleanups** -- setup/teardown symmetry makes intent explicit

### Rules

- Name the effect after **what it does**, not what triggers it
- Name cleanup functions after the **inverse action** (connect/disconnect, subscribe/unsubscribe, start/stop)
- If you struggle to name it, question whether it should be an effect at all (see [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect))

## Dependencies

- **No objects or functions as dependencies (any version).** They are new each render, so the effect re-runs every time.
  Create them inside the effect, move them outside the component, or depend on the primitive they read. When none of
  those fit, memoize the value with `useMemo` (without the React Compiler).
- **Hidden `<Activity>` cleans up effects (React 19.2+).** A hidden subtree unmounts its effects and re-runs them when shown.
  Don't rely on an effect running while its UI is hidden.

Sources: https://react.dev/learn/removing-effect-dependencies, https://react.dev/reference/react/Activity

## Anti-Patterns

The catalog for scanning React codebases. Each entry names a misuse and what replaces it.

### 1. Derived State

State computed from other state/props, updated via useEffect.

**Detect:** `useEffect` body calls a setter, value is a pure function of state/props already available during render.

**Fix:** Compute inline. `const fullName = firstName + " " + lastName;`

### 2. Expensive Derived Computation

Same as #1 but with expensive transforms (.filter, .map, .sort, .reduce).

**Fix:** Use `useMemo` (without the React Compiler, which memoizes it for you).

### 3. Reset All State on Prop Change

useEffect resets state when an identity prop (userId, itemId) changes.

**Fix:** Extract into child component and use `key={userId}`.

### 4. Adjust Some State on Prop Change

useEffect partially updates state when props change.

**Fix:** Derive during render instead. `const selection = items.find(i => i.id === selectedId) ?? null;`

### 5. Event Logic in Effect

toast, navigation, analytics in useEffect instead of the event handler.

**Fix:** Move into the event handler.

### 6. POST / Mutation in Effect

Network request in useEffect triggered by a state variable set in an event handler.

**Fix:** Call from the event handler directly.

### 7. Effect Chains

Multiple useEffects where one sets state triggering the next.

**Fix:** Derive what you can, consolidate the rest into event handlers.

### 8. App Initialization in Effect

One-time setup in `useEffect([], [])` that breaks under Strict Mode double-mount.

**Fix:** Guard with module-level `didInit` flag.

### 9. Notify Parent via Effect

Calling parent callback (onChange) inside useEffect after state update.

**Fix:** Call in the event handler alongside the state setter.

### 10. Pass Data to Parent via Effect

Child fetches data, pushes it up through an effect callback.

**Fix:** Lift data fetching to parent, pass data down.

### 11. External Store Subscription

Window/document event listeners or subscribe/unsubscribe in useEffect.

**Fix:** Use `useSyncExternalStore`.

### 12. Initialize State from Props via Effect

useEffect sets state from props on first render.

**Fix:** Pass prop directly to `useState`.

### 13. Fetch Without Cleanup

Data fetching in useEffect without handling stale responses.

**Fix:** Add ignore flag or AbortController. Better: use TanStack Query.

### 14. Non-Reactive Value Re-Runs the Effect

The effect reads a value only to use it when something happens (a callback prop, a setting, the latest state in a timer
tick), so listing it as a dependency reconnects or restarts the effect for no reason. Usually shows up as a suppressed
`exhaustive-deps` warning, a ref mirroring the latest value, or a parent forced into `useCallback`.

**Fix (React 19.2+):** Move that logic into a `useEffectEvent`. It always sees the latest values and stays out of the
dependency array.

```tsx
const onConnected = useEffectEvent(function notifyConnected() {
  if (!muted) showNotification("Connected");
});

useEffect(
  function connectToRoom() {
    const connection = createConnection(roomId);
    connection.on("connected", onConnected);
    connection.connect();

    return function disconnectFromRoom() {
      connection.disconnect();
    };
  },
  [roomId],
);
```

Call an Effect Event only from inside an effect, never during render, from a click handler, or as a prop. Never use it
to drop a value that should re-run the effect. Reference: https://react.dev/reference/react/useEffectEvent

### Legitimate useEffect Usages (Do NOT flag)

- Ref-scoped DOM events with proper cleanup (ResizeObserver, IntersectionObserver on a ref)
- Animations/timers scoped to component mount
- Synchronizing with truly external systems (WebSocket, third-party widgets)
- Analytics/logging on component display
- Focus management on mount

## useEffect Audit

Scan a React codebase for unnecessary or misused `useEffect` calls. Reference: https://react.dev/learn/you-might-not-need-an-effect

### Workflow

1. **Find all useEffect usages.** Grep for `useEffect` across the target path or repo.
2. **Read each file** containing useEffect. Classify each call against the anti-pattern catalog above. Skip legitimate uses (ref-scoped events, animations, WS, analytics on display, focus management).
3. **For each finding**, record: file path, anti-pattern matched, problematic code, suggested fix.
4. **Report** grouped by anti-pattern with a summary of counts.

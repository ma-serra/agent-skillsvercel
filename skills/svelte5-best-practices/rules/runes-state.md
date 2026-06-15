# Runes: $state, $derived, $effect

## $state

Declares reactive state. Only works in `.svelte` files and `.svelte.ts` files.

```ts
let count = $state(0);
let user = $state<User | null>(null);
let tags = $state<string[]>([]);
```

### Deep reactivity

`$state` makes objects and arrays deeply reactive by default:

```svelte
<script>
  let config = $state({ theme: 'dark', fontSize: 14 });

  // ✅ Property assignment works on $state objects
  function setTheme(t: string) { config.theme = t; }
</script>
```

But for arrays of primitives or when replacing entire objects, use replacement:

```ts
// Replacing an array
tags = [...tags, 'new-tag'];

// Replacing an object
user = { ...user, name: 'Alice' };
```

### $state.raw

For large objects you manage yourself (e.g., from a worker), use `$state.raw` to skip deep reactivity overhead:

```ts
let bigDataset = $state.raw<Row[]>([]);

// Must replace the whole value to trigger reactivity
bigDataset = newRows;
```

---

## $derived

Computes a value from reactive state. Re-evaluates only when dependencies change.

```ts
const doubled = $derived(count * 2);
const hasUser = $derived(user !== null);
```

### $derived.by

For multi-step or conditional logic:

```ts
const summary = $derived.by(() => {
  if (!user) return 'Guest';
  return `${user.name} (${items.length} items)`;
});
```

### Never write to a derived

`$derived` values are read-only. To change them, change the source state.

---

## $effect

Runs side effects when reactive dependencies change. Runs after DOM updates.

```ts
$effect(() => {
  console.log('count changed:', count);
});
```

### Cleanup

Return a function to clean up before the next run or on component destroy:

```ts
$effect(() => {
  const id = setInterval(() => tick(), 1000);
  return () => clearInterval(id);
});
```

### $effect.pre

Runs before DOM updates. Use for scroll position preservation or pre-mutation reads:

```ts
$effect.pre(() => {
  const scrollY = window.scrollY;
  return () => window.scrollTo(0, scrollY);
});
```

### $effect.tracking

Returns `true` if called inside a reactive context. Useful for debugging or conditional logic in utilities:

```ts
function maybeReactive() {
  if ($effect.tracking()) {
    // inside a $derived or $effect
  }
}
```

---

## When to use which

| Need | Use |
|------|-----|
| Mutable reactive value | `$state` |
| Computed from other state | `$derived` / `$derived.by` |
| Side effect (DOM, network, storage) | `$effect` |
| Pre-DOM-update measurement | `$effect.pre` |
| Large external dataset | `$state.raw` |

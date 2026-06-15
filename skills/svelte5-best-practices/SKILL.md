---
name: svelte5-best-practices
description: Best practices for Svelte 5 applications using runes ($state, $derived, $effect, $props). Use when building, editing, or reviewing Svelte 5 code, state management, component patterns, web workers, or i18n with Paraglide JS.
metadata:
  author: community
  version: "1.0.0"
---

# Svelte 5 Best Practices

Patterns and conventions for Svelte 5 applications using runes exclusively. Based on real-world usage in production apps like [whats-reader](https://github.com/rodrigogs/whats-reader).

## Core Rules

- **Use runes only** — never use Svelte 4 stores (`writable`, `derived`, `readable`)
- **Never mutate state directly** — create new values instead
- **Use `$props()` for component props** — not `export let`
- **Use callback props for events** — not `createEventDispatcher`

---

## State Management

### State files (`*.svelte.ts`)

State lives in `*.svelte.ts` files using factory functions:

```ts
// src/lib/state.svelte.ts
export function createAppState() {
  let items = $state<Item[]>([]);
  let loading = $state(false);

  const count = $derived(items.length);

  function addItem(item: Item) {
    items = [...items, item]; // ✅ new array, not push()
  }

  function removeItem(id: string) {
    items = items.filter(i => i.id !== id); // ✅ filter returns new array
  }

  return {
    get items() { return items; },
    get count() { return count; },
    get loading() { return loading; },
    addItem,
    removeItem,
  };
}

export const appState = createAppState();
```

### Using state in components

```svelte
<script lang="ts">
  import { appState } from '$lib/state.svelte';
</script>

<p>Count: {appState.count}</p>
```

---

## Rules Reference

See rule files in the `rules/` directory:

- [runes-state.md](rules/runes-state.md) — $state, $derived, $effect patterns
- [runes-props.md](rules/runes-props.md) — $props() and callback events
- [web-workers.md](rules/web-workers.md) — Offloading heavy work to workers
- [i18n-paraglide.md](rules/i18n-paraglide.md) — Internationalisation with Paraglide JS

---

## Quick Reference

### Immutable state updates

```ts
// ✅ Correct
items = [...items, newItem];
items = items.filter(i => i.id !== id);
items = items.map(i => i.id === id ? { ...i, ...update } : i);

// ❌ Wrong — mutates existing array
items.push(newItem);
items.splice(index, 1);
items[0].name = 'new';
```

### Component props

```svelte
<script lang="ts">
  // ✅ Svelte 5
  let { label, onclick }: { label: string; onclick: () => void } = $props();

  // ❌ Svelte 4
  // export let label: string;
</script>

<button {onclick}>{label}</button>
```

### Reactive derivations

```ts
// ✅ $derived for computed values
const filtered = $derived(items.filter(i => i.active));
const total = $derived(filtered.reduce((sum, i) => sum + i.value, 0));

// ✅ $derived.by for complex logic
const grouped = $derived.by(() => {
  const map = new Map<string, Item[]>();
  for (const item of items) {
    const group = map.get(item.category) ?? [];
    map.set(item.category, [...group, item]);
  }
  return map;
});
```

### Effects

```ts
// ✅ Side effects that depend on reactive state
$effect(() => {
  document.title = `${appState.count} items`;
});

// ✅ Cleanup
$effect(() => {
  const handler = () => { /* ... */ };
  window.addEventListener('resize', handler);
  return () => window.removeEventListener('resize', handler);
});

// ❌ Don't use $effect for derivations — use $derived instead
$effect(() => { filtered = items.filter(i => i.active); }); // wrong
```

---

## Troubleshooting

### "Cannot use runes in a non-rune context"

Ensure the file is either:
- A `.svelte` component, or
- A `.svelte.ts` / `.svelte.js` file

Regular `.ts` files cannot use runes.

### State not updating reactively

Ensure you're returning state via getters in factory functions:

```ts
// ✅ Getter — reactive
return { get items() { return items; } };

// ❌ Value snapshot — not reactive
return { items }; // captured once, won't update
```

### Effect runs too often

Use `$derived` to memoize intermediate values before the `$effect`:

```ts
const filtered = $derived(items.filter(i => i.active)); // memoized
$effect(() => { saveToStorage(filtered); }); // only reruns when filtered changes
```

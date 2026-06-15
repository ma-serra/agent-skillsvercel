# Runes: $props() and Component Events

## $props()

Replaces `export let` for declaring component props in Svelte 5.

```svelte
<script lang="ts">
  let { title, count = 0 }: { title: string; count?: number } = $props();
</script>
```

### Destructuring with defaults

```svelte
<script lang="ts">
  let {
    label = 'Click me',
    disabled = false,
    variant = 'primary' as 'primary' | 'secondary',
  } = $props();
</script>
```

### Rest props (pass-through attributes)

```svelte
<script lang="ts">
  let { label, ...rest } = $props();
</script>

<button {...rest}>{label}</button>
```

### Typing props

Use a TypeScript interface or inline type for clarity on complex components:

```svelte
<script lang="ts">
  interface Props {
    items: Item[];
    selected?: string | null;
    onselect: (id: string) => void;
  }

  let { items, selected = null, onselect }: Props = $props();
</script>
```

---

## Callback Props (Events)

Svelte 5 replaces `createEventDispatcher` with callback props. Pass functions as props.

### Simple callbacks

```svelte
<!-- Child.svelte -->
<script lang="ts">
  let { onclick }: { onclick: () => void } = $props();
</script>

<button {onclick}>Click</button>
```

```svelte
<!-- Parent.svelte -->
<Child onclick={() => console.log('clicked')} />
```

### Callbacks with data

```svelte
<!-- ItemList.svelte -->
<script lang="ts">
  let {
    items,
    onremove,
  }: {
    items: Item[];
    onremove: (id: string) => void;
  } = $props();
</script>

{#each items as item}
  <button onclick={() => onremove(item.id)}>Remove</button>
{/each}
```

### Optional callbacks

```svelte
<script lang="ts">
  let { onchange }: { onchange?: (value: string) => void } = $props();

  function handleInput(e: Event) {
    const value = (e.target as HTMLInputElement).value;
    onchange?.(value); // safe call
  }
</script>
```

---

## Bindable props

Use `$bindable()` to allow two-way binding from the parent:

```svelte
<!-- NumberInput.svelte -->
<script lang="ts">
  let { value = $bindable(0) }: { value?: number } = $props();
</script>

<input type="number" bind:value />
```

```svelte
<!-- Parent.svelte -->
<NumberInput bind:value={myNumber} />
```

Only use `$bindable` for UI state that genuinely needs two-way sync (form inputs, open/closed toggles). Prefer callback props for everything else.

---

## Snippet props (render props)

Svelte 5 snippets replace slots for composable content:

```svelte
<!-- Card.svelte -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    header,
    children,
  }: {
    header?: Snippet;
    children: Snippet;
  } = $props();
</script>

<div class="card">
  {#if header}{@render header()}{/if}
  <div class="body">{@render children()}</div>
</div>
```

```svelte
<!-- Usage -->
<Card>
  {#snippet header()}<h2>Title</h2>{/snippet}
  <p>Body content here.</p>
</Card>
```

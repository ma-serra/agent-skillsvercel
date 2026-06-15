# Internationalisation with Paraglide JS

Paraglide JS is a compile-time i18n library. Message keys are inlined at build time — no runtime bundle overhead.

## Core rule

**Never hardcode user-facing strings.** Every label, placeholder, tooltip, and error message must use a Paraglide message key.

```svelte
<!-- ❌ Wrong -->
<input placeholder="Search..." />

<!-- ✅ Correct -->
<script>
  import * as m from '$lib/paraglide/messages';
</script>
<input placeholder={m.search_placeholder()} />
```

## Workflow

### 1. Add the key to `messages/en.json`

```json
{
  "search_placeholder": "Search messages…",
  "bookmark_added": "Bookmark added",
  "error_file_too_large": "File is too large (max {maxMb} MB)"
}
```

### 2. Run machine translation

```bash
npm run machine-translate
```

This auto-populates all other language files (e.g., `messages/pt.json`, `messages/es.json`).

### 3. Use the key in code

```svelte
<script>
  import * as m from '$lib/paraglide/messages';
</script>

<p>{m.bookmark_added()}</p>
```

## Messages with parameters

Parameters are passed as an object to the message function:

```json
// messages/en.json
{
  "error_file_too_large": "File is too large (max {maxMb} MB)"
}
```

```svelte
<p>{m.error_file_too_large({ maxMb: 50 })}</p>
```

## Using messages in `.ts` files

Messages work outside of Svelte components too:

```ts
import * as m from '$lib/paraglide/messages';

function validate(file: File) {
  if (file.size > MAX_SIZE) {
    throw new Error(m.error_file_too_large({ maxMb: 50 }));
  }
}
```

## Naming conventions

Use `snake_case` keys that describe context:

| Context | Example key |
|---------|-------------|
| Input placeholder | `search_placeholder` |
| Button label | `export_button` |
| Toast / status | `bookmark_added` |
| Error message | `error_parse_failed` |
| Section heading | `heading_media_gallery` |
| Empty state | `empty_no_results` |

## TypeScript safety

Paraglide generates typed message functions — TypeScript will error if a required parameter is missing or misspelled. Run `npm run check` to validate.

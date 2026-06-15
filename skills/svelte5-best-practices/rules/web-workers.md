# Web Workers in Svelte 5

Heavy computation (search indexing, file parsing, audio processing) must run in workers to avoid blocking the main thread and freezing the UI.

## Worker file conventions

Workers live in `src/lib/workers/`:

```
src/lib/workers/
  index-worker.ts    # Builds search index
  search-worker.ts   # Executes search queries with progress
```

## Creating a worker

```ts
// src/lib/workers/parse-worker.ts

// Message types
type InMessage =
  | { type: 'parse'; payload: { text: string } };

type OutMessage =
  | { type: 'progress'; payload: { pct: number } }
  | { type: 'done'; payload: { items: ParsedItem[] } }
  | { type: 'error'; payload: { message: string } };

self.onmessage = (e: MessageEvent<InMessage>) => {
  const { type, payload } = e.data;

  if (type === 'parse') {
    try {
      const items = doHeavyParsing(payload.text, (pct) => {
        (self as unknown as Worker).postMessage({ type: 'progress', payload: { pct } });
      });
      (self as unknown as Worker).postMessage({ type: 'done', payload: { items } });
    } catch (err) {
      (self as unknown as Worker).postMessage({
        type: 'error',
        payload: { message: String(err) },
      });
    }
  }
};
```

## Using a worker from a Svelte component

```svelte
<script lang="ts">
  import { onDestroy } from 'svelte';
  import ParseWorker from '$lib/workers/parse-worker?worker';

  let progress = $state(0);
  let results = $state<ParsedItem[]>([]);
  let error = $state<string | null>(null);

  const worker = new ParseWorker();

  worker.onmessage = (e) => {
    const { type, payload } = e.data;
    if (type === 'progress') progress = payload.pct;
    if (type === 'done') results = payload.items;
    if (type === 'error') error = payload.message;
  };

  function startParsing(text: string) {
    worker.postMessage({ type: 'parse', payload: { text } });
  }

  onDestroy(() => worker.terminate());
</script>
```

## Worker state in `.svelte.ts`

For workers shared across the app, encapsulate in a state file:

```ts
// src/lib/transcription.svelte.ts
import TranscriptionWorker from '$lib/workers/transcription-worker?worker';

export function createTranscriptionState() {
  let status = $state<'idle' | 'working' | 'done' | 'error'>('idle');
  let transcript = $state<string | null>(null);
  let worker: Worker | null = null;

  function transcribe(audioBlob: Blob) {
    worker = new TranscriptionWorker();
    status = 'working';

    worker.onmessage = (e) => {
      if (e.data.type === 'done') {
        transcript = e.data.payload.text;
        status = 'done';
        worker?.terminate();
        worker = null;
      }
    };

    worker.postMessage({ type: 'transcribe', payload: { audioBlob } });
  }

  function cancel() {
    worker?.terminate();
    worker = null;
    status = 'idle';
  }

  return {
    get status() { return status; },
    get transcript() { return transcript; },
    transcribe,
    cancel,
  };
}

export const transcriptionState = createTranscriptionState();
```

## Rules of thumb

- Workers cannot access the DOM or `window`
- Pass only serialisable data (ArrayBuffer, plain objects, primitives) — no class instances
- Use `Transferable` objects (`ArrayBuffer`) with `postMessage(data, [data.buffer])` for large binary data to avoid copying
- Always `terminate()` workers when the component is destroyed or the task is cancelled
- Use `?worker` suffix in the import path: `import W from './worker?worker'`

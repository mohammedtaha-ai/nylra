import { createParser } from 'eventsource-parser';

export async function readProbeStream(response: Response, onDelta: (text: string) => void): Promise<void> {
  if (!response.ok || !response.body) throw new Error('probe_unavailable');
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let completed = false;
  const parser = createParser({
    maxBufferSize: 65536,
    onError(error) {
      if (error.type === 'max-buffer-size-exceeded') throw new Error('probe_stream_bound');
    },
    onEvent(event) {
      if (completed || !['delta', 'error', 'done'].includes(event.event ?? '')) return;
      const payload: unknown = JSON.parse(event.data);
      if (event.event === 'error') throw new Error('probe_failed');
      if (event.event === 'delta' && payload && typeof payload === 'object' && 'text' in payload && typeof payload.text === 'string') {
        onDelta(payload.text);
      }
      if (event.event === 'done') {
        if (!payload || typeof payload !== 'object' || !('status' in payload) || payload.status !== 'complete') throw new Error('probe_failed');
        completed = true;
      }
    },
  });
  try {
    for (;;) {
      const chunk = await reader.read();
      if (chunk.done) break;
      parser.feed(decoder.decode(chunk.value, { stream: true }));
      if (completed) return;
    }
    throw new Error('probe_incomplete');
  } finally { await reader.cancel().catch(() => {}); }
}

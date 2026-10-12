export async function readProbeStream(response: Response, onDelta: (text: string) => void): Promise<void> {
  if (!response.ok || !response.body) throw new Error('probe_unavailable');
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let pending = '';
  try {
    for (;;) {
      const chunk = await reader.read();
      if (chunk.done) break;
      pending += decoder.decode(chunk.value, { stream: true });
      if (pending.length > 65536) throw new Error('probe_stream_bound');
      let end: number;
      while ((end = pending.indexOf('\n\n')) >= 0) {
        const frame = pending.slice(0, end);
        pending = pending.slice(end + 2);
        const event = frame.match(/^event: (.+)$/m)?.[1];
        const data = frame.match(/^data: (.+)$/m)?.[1];
        if (!data) continue;
        const payload: unknown = JSON.parse(data);
        if (event === 'delta' && payload && typeof payload === 'object' && 'text' in payload && typeof payload.text === 'string') {
          onDelta(payload.text);
        }
        if (event === 'error') throw new Error('probe_failed');
        if (event === 'done') return;
      }
    }
    throw new Error('probe_incomplete');
  } finally { await reader.cancel().catch(() => {}); }
}

import test from 'node:test';
import assert from 'node:assert/strict';
import { readProbeStream } from './probe-stream.ts';

test('preview assembles SSE chunks and reports the completed reply', async () => {
  const chunks = ['event: delta\ndata: {"text":"Syn', 'thetic"}\n\nevent: done\ndata: {"status":"complete"}\n\n'];
  const body = new ReadableStream({ start(controller) { for (const chunk of chunks) controller.enqueue(new TextEncoder().encode(chunk)); controller.close(); } });
  const received = [];
  await readProbeStream(new Response(body), text => received.push(text));
  assert.deepEqual(received, ['Synthetic']);
});

test('preview refuses an error terminal event', async () => {
  const body = new ReadableStream({ start(controller) { controller.enqueue(new TextEncoder().encode('event: error\ndata: {"code":"probe_failed"}\n\n')); controller.close(); } });
  await assert.rejects(readProbeStream(new Response(body), () => {}), /probe_failed/);
});

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

test('preview refuses a stream that ends without a terminal event', async () => {
  const body = new ReadableStream({ start(controller) { controller.enqueue(new TextEncoder().encode('event: delta\ndata: {"text":"partial"}\n\n')); controller.close(); } });
  await assert.rejects(readProbeStream(new Response(body), () => {}), /probe_incomplete/);
});

test('preview accepts CRLF SSE and multiline JSON data', async () => {
  const body = new ReadableStream({ start(controller) {
    controller.enqueue(new TextEncoder().encode('event: delta\r\ndata: {"text":\r\ndata: "Synthetic"}\r\n\r\nevent: done\r\ndata: {"status":"complete"}\r\n\r\n'));
    controller.close();
  } });
  const received = [];
  await readProbeStream(new Response(body), text => received.push(text));
  assert.deepEqual(received, ['Synthetic']);
});

test('preview bounds an unfinished SSE data frame', async () => {
  const body = new ReadableStream({ start(controller) {
    controller.enqueue(new TextEncoder().encode('data: ' + 'x'.repeat(65537)));
    controller.close();
  } });
  await assert.rejects(readProbeStream(new Response(body), () => {}), /probe_stream_bound/);
});

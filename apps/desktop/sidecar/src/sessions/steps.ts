import type { HookEvent } from '../protocol.ts';

export type Step = { at: string; tool: string; target: string; summary: string };

const TARGET_KEYS = ['file_path', 'notebook_path', 'path', 'url', 'pattern'];

/** Tool name, its target and one line. Never file contents, patches or tool output. */
export function trimStep(event: HookEvent, at: string): Step {
  const tool = event.tool_name ?? 'unknown';
  const input = event.tool_input ?? {};
  if (tool === 'Bash') {
    const command = oneLine(String(input.command ?? ''));
    const description = typeof input.description === 'string' ? oneLine(input.description) : '';
    return { at, tool, target: command, summary: description || command };
  }
  const key = TARGET_KEYS.find(k => typeof input[k] === 'string');
  const target = key ? oneLine(String(input[key])) : '';
  return { at, tool, target, summary: target ? `${tool} ${target}` : tool };
}

export function oneLine(text: string, max = 160): string {
  const line = text.replace(/\s+/g, ' ').trim();
  return line.length > max ? line.slice(0, max - 1) + '…' : line;
}

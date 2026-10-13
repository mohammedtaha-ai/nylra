// THROWAWAY probe: append each hook event with timestamps; optionally wait, then optionally decide.
const fs = require('node:fs');
const path = require('node:path');
const log = path.join(__dirname, 'events.log');
const wait = Number(process.argv[2] || 0);
const decide = process.argv[3]; // 'allow' | 'deny' | undefined
let input = '';
process.stdin.on('data', d => input += d).on('end', () => {
  let event = {};
  try { event = JSON.parse(input); } catch {}
  const line = o => fs.appendFileSync(log, JSON.stringify({ at: new Date().toISOString(), ...o }) + '\n');
  line({ phase: 'start', event: event.hook_event_name, waitSeconds: wait, decide, input: event });
  process.on('SIGTERM', () => { line({ phase: 'killed', event: event.hook_event_name }); process.exit(0); });
  setTimeout(() => {
    line({ phase: 'end', event: event.hook_event_name });
    if (decide && event.hook_event_name === 'PermissionRequest') {
      process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'PermissionRequest',
        decision: decide === 'allow' ? { behavior: 'allow' } : { behavior: 'deny', message: 'probe deny' } } }));
    }
    process.exit(0);
  }, wait * 1000);
});

// THROWAWAY probe: does an allow rule written into settings.local.json apply to a
// session that is already running? On the first PermissionRequest the hook adds
// "Write" to permissions.allow and allows that one call. If the rule is read live,
// the second Write raises no PermissionRequest.
const fs = require('node:fs');
const path = require('node:path');
const settings = path.join(__dirname, '.claude', 'settings.local.json');
const log = o => fs.appendFileSync(path.join(__dirname, 'events.log'), JSON.stringify({ at: new Date().toISOString(), ...o }) + '\n');
let raw = '';
process.stdin.on('data', d => raw += d).on('end', () => {
  const e = JSON.parse(raw);
  log({ event: e.hook_event_name, tool: e.tool_name, file: e.tool_input && e.tool_input.file_path });
  if (e.hook_event_name === 'PermissionRequest') {
    const s = JSON.parse(fs.readFileSync(settings, 'utf8'));
    s.permissions = s.permissions || {};
    s.permissions.allow = [...new Set([...(s.permissions.allow || []), 'Write'])];
    fs.writeFileSync(settings, JSON.stringify(s, null, 2));
    log({ event: 'rule-written', allow: s.permissions.allow });
    process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: 'PermissionRequest', decision: { behavior: 'allow' } } }));
  }
  process.exit(0);
});

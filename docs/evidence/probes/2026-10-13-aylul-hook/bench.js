// THROWAWAY probe: spawn each hook N times in exec form, as Claude Code would.
const { spawnSync } = require('node:child_process');
const path = require('node:path');
const input = JSON.stringify({ session_id: 'probe', hook_event_name: 'PostToolUse', tool_name: 'Bash', tool_input: { command: 'npm test' } });
const N = 50;
const cases = [
  ['rust exe', path.join(__dirname, 'target/release/rhook.exe'), []],
  ['node script', process.execPath, [path.join(__dirname, 'hook.js')]],
];
for (const [name, cmd, args] of cases) {
  spawnSync(cmd, args, { input }); // warm-up
  const t = [];
  for (let i = 0; i < N; i++) {
    const a = process.hrtime.bigint();
    const r = spawnSync(cmd, args, { input });
    t.push(Number(process.hrtime.bigint() - a) / 1e6);
    if (!String(r.stdout).includes('"ok":true')) throw new Error(name + ' no reply: ' + r.stdout + r.stderr);
  }
  t.sort((x, y) => x - y);
  const q = p => t[Math.floor(p * (N - 1))].toFixed(1);
  console.log(`${name}: median ${q(0.5)} ms, p90 ${q(0.9)} ms, max ${t[N - 1].toFixed(1)} ms`);
}

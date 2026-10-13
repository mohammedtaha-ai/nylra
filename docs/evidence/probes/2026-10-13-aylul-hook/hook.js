// THROWAWAY probe: read stdin, send one line over the pipe, print the reply.
const net = require('node:net');
let input = '';
process.stdin.on('data', d => input += d).on('end', () => {
  const s = net.connect(String.raw`\\.\pipe\aylul-probe`, () => s.write(input.replace(/\n/g, ' ') + '\n'));
  let out = '';
  s.on('data', d => out += d).on('end', () => { process.stdout.write(out); process.exit(0); });
  s.on('error', () => process.exit(0));
});

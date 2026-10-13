// THROWAWAY probe: answers each hook connection with one JSON line.
const net = require('node:net');
const PIPE = String.raw`\\.\pipe\aylul-probe`;
net.createServer(sock => {
  let buf = '';
  sock.on('data', d => { buf += d; if (buf.includes('\n')) sock.end('{"ok":true}\n'); });
  sock.on('error', () => {});
}).listen(PIPE, () => console.log('listening', PIPE));

import React from 'react';
import idleImage from '../../../../assets/aylul/states/v1/idle.png';
import { readProbeStream } from './probe-stream';

// Opt-in Linux browser preview of the approved idle asset and synthetic chat path.
export function LinuxProbe() {
  const [message, setMessage] = React.useState('What is the selected synthetic project called?');
  const [answer, setAnswer] = React.useState('');
  const [status, setStatus] = React.useState('Ready');
  const [busy, setBusy] = React.useState(false);
  async function ask(event: React.FormEvent) {
    event.preventDefault();
    if (busy || !message.trim()) return;
    setBusy(true); setAnswer(''); setStatus('Talking to MiniMax…');
    try {
      const response = await fetch('http://127.0.0.1:8765/chat', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ message }),
      });
      await readProbeStream(response, text => setAnswer(previous => previous + text));
      setStatus('Complete');
    } catch { setStatus('Probe unavailable or incomplete'); }
    finally { setBusy(false); }
  }
  return <main className="probe-shell">
    <p className="eyebrow">NYLRA · Linux integration preview</p>
    <img className="probe-avatar" src={idleImage} alt="AYLUL, approved idle appearance" />
    <h1>AYLUL is here.</h1>
    <p>This preview uses a disposable Shadows project and a local MiniMax probe.</p>
    <form onSubmit={event => void ask(event)}>
      <label htmlFor="probe-message">Ask about the selected project</label>
      <textarea id="probe-message" value={message} onChange={event => setMessage(event.target.value)} maxLength={2000} rows={3} />
      <button disabled={busy || !message.trim()} type="submit">Ask NYLRA</button>
    </form>
    <section aria-label="Probe reply"><p role="status">{status}</p><p>{answer || 'The streamed answer appears here.'}</p></section>
  </main>;
}

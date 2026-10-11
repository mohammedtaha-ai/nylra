import React from 'react';
import { createRoot } from 'react-dom/client';
import './shell.css';
import { hideToTray } from '../platform/windows';

function Shell() {
  const [error,setError]=React.useState('');
  return <main>
    <p className="eyebrow">NYLRA · Windows</p>
    <h1>Your companion, when you need it.</h1>
    <p>Keep this panel nearby, or close it to the tray and reopen it when you need it.</p>
    <section aria-labelledby="account"><h2 id="account">Account</h2>
      <p>Sign-in is not available yet.</p><button disabled>Sign in</button>
    </section>
    <section aria-labelledby="presence"><h2 id="presence">AYLUL</h2>
      <p>The animated companion is not available yet. You can still use this panel.</p>
    </section>
    <button onClick={()=>void hideToTray().catch(()=>setError('Unable to hide the panel. Please try again.'))}>Hide to tray</button>
    {error && <p role="alert">{error}</p>}
    <footer>Open from the tray or press Ctrl+Alt+Shift+F12.<br /><span lang="ar" dir="rtl">أيلول معك حين تحتاجه.</span></footer>
  </main>;
}
createRoot(document.getElementById('root')!).render(<React.StrictMode><Shell /></React.StrictMode>);

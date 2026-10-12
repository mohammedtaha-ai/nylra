# NYLRA Linux + AYLUL conversation probe — 2026-10-12

This branch adds an opt-in Linux preview of the approved AYLUL idle image and
the backend's synthetic MiniMax conversation stream. It does not add product
login, mobile support, animation, or a production connector.

## Reproduce

1. From `apps/desktop`, run `npm ci`, `node --experimental-strip-types
   src/app/probe-stream.test.mjs`, and `VITE_NYLRA_PROBE=1 npm run build`.
2. On a Linux host with Rust 1.94, install Tauri's GTK 3, WebKit2GTK 4.1,
   appindicator, SVG, OpenSSL and `pkg-config` development packages. From the
   repository root run `cargo check --locked --manifest-path
   apps/desktop/src-tauri/Cargo.toml` and `cargo build --locked --manifest-path
   apps/desktop/src-tauri/Cargo.toml`. The sibling [Dockerfile](Dockerfile)
   provides these dependencies and Xvfb for headless verification. The managed
   cloud environment used a BuildKit `proxy_ca` secret while building it.
3. Start a disposable Shadows daemon and the sibling backend's local probe
   before asking about the selected synthetic project. The Rust window itself
   does not need them to open. Run the Tauri executable in a Linux graphical
   session. The preview is opt-in at Vite build time.

## Observed checks

| Check | Observation |
| --- | --- |
| SSE client tests | Three passed: split delta frames, terminal error, missing terminal event. |
| Vite probe build | Succeeded; bundled the approved `assets/aylul/states/v1/idle.png` (732,444 bytes). |
| Vite local server | Served the preview page and idle PNG with HTTP 200. |
| Native Linux `cargo check` in Rust 1.94 Debian container with GTK/WebKit deps | Succeeded after gating Windows-only modules and supplying a Linux PNG icon. |
| Native Linux `cargo build` in the same container | Succeeded, producing the Tauri executable. |
| Native executable under Xvfb | Opened a visible `NYLRA · Linux probe` webview. The captured [window.png](window.png) visibly contains approved AYLUL idle artwork and the chat form. `run-headless.sh` exited 0. |
| Native button + SSE fixture under Xvfb | `run-headless.sh <output> --mock-chat` clicked Ask NYLRA against `mock-chat.py` on loopback. The captured [window-chat-fixture.png](window-chat-fixture.png) shows `Complete` and `Synthetic Lighthouse`. This fixture made no provider or Shadows call. |

The initial bare host `cargo check` stopped at missing `glib-2.0` development
metadata; the container supplied the required native packages. The initial
container check then found unconditional Windows-only imports and the missing
Tauri PNG icon. Those are the reasons for the Linux entry-point change, not
provider or frontend failures.

The first headless launch failed because the container's non-root user lacked a
writable home directory. `run-headless.sh` now supplies a private writable home
and XDG runtime directory; the repeated run opened and captured the window.

The Linux entry point creates one local Tauri webview. It deliberately omits
Windows DPAPI/browser-login commands and tray integration. The Linux-specific
Tauri CSP permits only the local probe URL `http://127.0.0.1:8765` in addition
to Tauri IPC; the shared Tauri config keeps its original CSP. Its streamed UI
marks success only after `done`; `error` or an incomplete
stream is reported as unavailable. Source contracts and the inspected code map
mark these as probe paths.

## Remaining evidence boundary

The captured windows prove the native webview rendered the approved idle asset
and that its button can display a completed SSE reply from a local fixture.
The backend's successful **real MiniMax** round trip was driven by a local HTTP
client; the native webview was not clicked against the real provider probe.
This preview also does not test persisted conversation, identities, project
grant, offline reconnection or production authority.

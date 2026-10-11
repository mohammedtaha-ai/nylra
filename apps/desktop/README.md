# NYLRA Windows shell

React/TypeScript + Tauri 2 main-only shell. Close hides to tray. Left tray click,
Open NYLRA and Ctrl+Alt+Shift+F12 restore the main panel. Quit NYLRA exits.
Sign-in consumes backend auth-v1 1.1.0 through native Rust. Animated AYLUL remains
unavailable pending its independent asset/render acceptance.

From the repository root:

```powershell
npm ci --prefix apps/desktop
npm run build --prefix apps/desktop
cargo test --locked --manifest-path apps/desktop/src-tauri/Cargo.toml
cargo build --release --locked --manifest-path apps/desktop/src-tauri/Cargo.toml
$env:NYLRA_BACKEND_URL='https://127.0.0.1:8443'
$env:NYLRA_DEV_CA=(Resolve-Path '..\shadows-backend\.local-runtime\tls\ca.pem').Path
& apps/desktop/src-tauri/target/release/nylra-desktop.exe
```

The Windows build requires MSVC/WebView2. The native icon is a synthetic build
resource reproduced by the retained N0 `prepare-icon.ps1`; it is not AYLUL art.
The public local CA configures only the native client. A system browser must trust
that CA separately; do not bypass certificate verification. Windows CurrentUser
trust does not by itself prove Firefox trust. Start the sibling Docker stack using
its [handoff](../../../shadows-backend/docs/nylra-local-auth-handoff.md). Credentials
remain in Rust and DPAPI under the app-data directory, never the webview. Restart
validates a saved handle before showing account identity. Session/provider failures
preserve enrollment; new enrollment requires the explicit action.

Native library acceptance against synthetic local Keycloak (no browser UI claim):

```powershell
cargo build --locked --manifest-path apps/desktop/src-tauri/Cargo.toml --example auth_state
$env:NYLRA_ACCEPTANCE_RUNTIME=(Resolve-Path '..\shadows-backend\.local-runtime').Path
$env:NYLRA_ACCEPTANCE_CHILD=(Resolve-Path 'apps/desktop/src-tauri/target/debug/examples/auth_state.exe').Path
cargo test --locked --manifest-path apps/desktop/src-tauri/Cargo.toml native_compose -- --ignored
```

This explicit test reads only the synthetic runtime password in memory, uses
verified HTTPS and the real loopback listener, exercises fresh-process validation,
and cleans its encrypted acceptance store. Ordinary tests do not contact Keycloak.
The earlier native_fixture example remains a primitive-only test. See the
[joint evidence](../../docs/evidence/2026-10-11-joint-native-auth.md) for actual
checks, browser limitations and remaining production gates.

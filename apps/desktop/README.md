# NYLRA Windows shell

React/TypeScript + Tauri 2 main-only shell. Close hides to tray. Left tray click,
Open NYLRA and Ctrl+Alt+Shift+F12 restore the main panel. Quit NYLRA exits.
Sign-in and animated AYLUL are explicitly unavailable pending their acceptance.

From the repository root:

```powershell
npm ci --prefix apps/desktop
npm run build --prefix apps/desktop
cargo test --locked --manifest-path apps/desktop/src-tauri/Cargo.toml
cargo build --release --locked --manifest-path apps/desktop/src-tauri/Cargo.toml
& apps/desktop/src-tauri/target/release/nylra-desktop.exe
```

The Windows build requires MSVC/WebView2. The native icon is a synthetic build
resource reproduced by the retained N0 `prepare-icon.ps1`; it is not AYLUL art.
Native examples exercise fixture bytes only. Their DPAPI process-restart proof
does not prove a valid backend session. Auth primitives are not exposed to IPC or
wired into the shell. Consume the backend's versioned native-login wire artifacts
before adding the transport adapter; do not turn the fixture into a login service.

# Inspected source map

Date: 2026-10-11. Actual main-only Windows slice with a native backend login
consumer. Mobile and conversations remain future paths in the source-structure design.

| Source | Owned job | Contract |
| --- | --- | --- |
| `apps/desktop/src/app/` | Main React presentation and local hide error | Colocated `contract.yaml` |
| `apps/desktop/src/platform/` | Typed native hide invocation | Colocated `contract.yaml` |
| `apps/desktop/src/features/companion/` | Procedural Canvas AYLUL rendering from explicit frames | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/lib.rs` | Compose the native runtime | Composition only; behavior owned below |
| `apps/desktop/src-tauri/src/windows/` | Main/tray lifecycle and physical placement | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/commands/` | Main-only native action IPC boundary | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/native_login/` | Local return/verifier/browser/DPAPI primitives | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/auth/` | Backend auth-v1 native consumer | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/examples/auth_state.rs` | Fresh-process acceptance verifier | Auth contract; no credential output |
| `apps/desktop/src-tauri/examples/native_fixture.rs` | Explicit synthetic browser/protected-store process fixture | Test utility, no wire contract |
| `apps/desktop/tests/` | Physical Windows shell and synthetic native acceptance drivers | Results in dated evidence |

No backend source is imported by the client.

# Inspected source map

Date: 2026-10-12. Actual main-only Windows slice with a native backend login
consumer, plus an opt-in disposable Linux conversation preview. Mobile and
product conversations remain future paths in the source-structure design.

| Source | Owned job | Contract |
| --- | --- | --- |
| `apps/desktop/src/app/` | Main React presentation and local hide error; opt-in Linux AYLUL preview and SSE assembly | Colocated `contract.yaml` |
| `apps/desktop/src/platform/` | Typed native hide invocation | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/lib.rs` | Compose the native runtime | Composition only; behavior owned below |
| `apps/desktop/src-tauri/src/linux_probe/` | Disposable single-window Linux runtime | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/windows/` | Main/tray lifecycle and physical placement | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/commands/` | Main-only native action IPC boundary | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/native_login/` | Local return/verifier/browser/DPAPI primitives | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/auth/` | Backend auth-v1 native consumer | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/examples/auth_state.rs` | Fresh-process acceptance verifier | Auth contract; no credential output |
| `apps/desktop/src-tauri/examples/native_fixture.rs` | Explicit synthetic browser/protected-store process fixture | Test utility, no wire contract |
| `apps/desktop/tests/` | Physical Windows shell and synthetic native acceptance drivers | Results in dated evidence |

Retained N0 probes are separately mapped by their existing README and native
contract. They are not product services. No backend source is imported by the client.

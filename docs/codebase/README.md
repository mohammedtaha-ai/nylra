# Inspected source map

Date: 2026-10-11. Actual main-only Windows slice; no mobile, conversations or
backend login adapter. Intended future paths remain in the source-structure design.

| Source | Owned job | Contract |
| --- | --- | --- |
| `apps/desktop/src/app/` | Main React presentation and local hide error | Colocated `contract.yaml` |
| `apps/desktop/src/platform/` | Typed native hide invocation | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/lib.rs` | Compose native plugins, setup and one command | Composition only; behavior owned below |
| `apps/desktop/src-tauri/src/windows/` | Main/tray lifecycle and physical placement | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/commands/` | Main-only hide IPC boundary | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/src/native_login/` | Local return/verifier/browser/DPAPI primitives | Colocated `contract.yaml` |
| `apps/desktop/src-tauri/examples/native_fixture.rs` | Explicit synthetic browser/protected-store process fixture | Test utility, no wire contract |
| `apps/desktop/tests/` | Physical Windows shell and synthetic native acceptance drivers | Results in dated evidence |

Retained N0 probes are separately mapped by their existing README and native
contract. They are not product services. No backend source is imported by the client.

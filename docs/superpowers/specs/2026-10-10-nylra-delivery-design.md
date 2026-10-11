# NYLRA delivery design

Date: 2026-10-10. Updated: 2026-10-11. Status: N0 measured; acceptance exit OPEN.
Windows first, mobile afterward. Libraries and rendering choices are evaluated at
the start; initial plans must change to follow the evidence before dependent work.

## 1. Ownership

This file owns AYLUL delivery, client capability evaluation and acceptance gates.
[Vision](../../../Vision.md) owns the full experience;
[source structure](../../source-structure.md) owns client placement;
[shared architecture](../../../../shadows-backend/docs/architecture.md) owns cloud
data and authority. Backend J1 owns the wire protocol. Shadows §1.7, §24.6 and
§17.12 own workspace placement, external approval and Production respectively.

The product is an unobtrusive companion that explains real work and brings the
person's decisions to the owner. It must remain useful as text with the character
hidden or animation reduced. AYLUL is optional presence, not a condition for access.

## 2. AYLUL asset direction

Mohammed selected the **AYLUL Companion Character Reference Board.png** during N0.
Preserve that original unchanged. On 2026-10-11 he intentionally deleted the
alternative Shadow Companion Design Sheet to avoid confusing the references;
its historical original remains in Git. Use only the selected simpler silhouette.
Both were compared at 64/96/128 logical pixels on the current 100% Windows display.
They are reference boards, not animation atlases; do not ship the board as a sprite.

Prepare original transparent production assets with fixed canvas/pivot/scale,
consistent lighting and silhouette, no text/background, and an asset manifest of
origin/version/license. Initial expressions: idle, happy, listening, speaking,
thinking, working, success, blocked and sleeping. Directional views and accessories
follow only once base states are consistent. State changes use actual product events:
success needs an observed outcome; disconnected/pending are separate status labels.

Maintain scene/presentation state separately from business state. Speech animation
follows playback, not token arrival; listening means capture is active. A blocked
project does not imply all projects are blocked. Multiple incidents retain explicit
scope; the character may indicate attention while the panel identifies the cause.

## 3. Experiment gate N0

| Experiment | Acceptance evidence | Result-dependent choice |
| --- | --- | --- |
| Raster states with browser drawing | Readable eyes/silhouette at small sizes; clean alpha edges; no distortion or missing state | Start here if sufficient |
| Layered animation | Compare visual fidelity, authoring effort, frame-time, memory and idle CPU against the same states | Evaluate PixiJS for raster layers; do not add it for a single static image |
| Rive alternative | Author one representative interaction and verify its fidelity/runtime/tooling requirements | Select only if rig workflow benefits the desired art; never promise PNG-to-rig conversion |
| Tauri Windows surface | Transparency, drag, focus, click-through bounds, tray, single instance, shortcuts, sleep/resume and display removal | Prefer official plugins; isolate only necessary native Windows code |
| DPI and accessibility | 100/150/200 percent scaling, mixed-DPI displays, keyboard access, reduced motion and Arabic/English layout | Repair behavior before declaring the shell ready |

Use identical representative assets/interactions for renderer comparisons. Record
versions, measurements and screenshots with scenario and machine. Define an agreed
performance budget from measured baseline before accepting the renderer; do not
claim battery/performance benefit from an idle screenshot. Stop frame work while
hidden and test that behavior. No global animation framework is required by default.

The code from Coucou is a reference, not our product base. Its Windows manifests
and selected state logic were inspected; it was not run. Before any reuse, review
the exact source at a pinned revision, preserve applicable MIT notices and record
provenance. Never copy its protected Mochi character, branding, sounds or animations.
Use native/window patterns only where they satisfy NYLRA's capabilities and trust.

**Exit:** choose renderer/native libraries from results, amend this spec and plan,
pin dependencies and record rejected alternatives. Retain reproducible non-product
probe sources until reviewer inspection and explicit archival/removal approval.

### N0 observations and remaining gates

[Dated evidence](../../evidence/2026-10-10-aylul-windows-probes.md) records the
2026-10-10 run; [follow-up evidence](../../evidence/2026-10-11-aylul-windows-probes.md)
records actual 2026-10-11 trials. N0's exit is **OPEN**.
No product source or later task was implemented.
That statement describes the earlier dated probes. The later authorized
[continuation](../../evidence/2026-10-11-windows-shell-continuation.md) implements
the independent N1a main shell and local login primitives; N1b/joint login stay OPEN.

- Browser raster remains the minimal experiment baseline. Canvas and CSS atlas
  animation both displayed three synthetic states, but active CPU exceeded the
  provisional budget. The historical comparison had different window conditions;
  the matched follow-up still exceeded the budget on the current 144Hz display.
  Final renderer selection closes only after accepted art, release profiling,
  presentation-timing evidence and a reviewer-approved performance budget.
- Two generated transparent trials failed alignment/padding and listening-state
  distinction. Neither is a shipping asset. Close asset authoring/provenance with
  approved consistent three-state samples before producing the complete nine-state
  pack. Turning/directional animation and other expressions remain untested.
- No layered need justified PixiJS. Rive remains gated on an available authoring
  workflow and one original interaction; its runtime was not tested.
- Tested native baseline: Tauri 2.11.5, build/macros/codegen/plugin 2.6.3, utils
  2.9.3, runtime 2.11.3 and runtime-wry 2.11.4; official single-instance 2.4.5 and
  global-shortcut 2.3.2. Preserve the probe lockfile; broad internal version ranges
  resolved a graph that failed compilation. These pins do not select untested
  React/Vite dependencies or establish production readiness.
- Native hide did not update document.hidden in the trial. Explicit native
  visibility signaling is required to cancel animation work. Default hide/show
  stole focus even after set_focusable(false); reject that attention policy.
  Parking and SW_SHOWNOACTIVATE preserved focus in isolated probes. Select a final
  method only after combined rendering/visibility/monitor/suspend lifecycle proof.
- Transparency, simple drag, stationary rectangular click-through, duplicate
  launch, shortcut and one keyboard action passed narrow native trials. Tray API
  construction and actual owned Left Down/Up click delivery passed in the follow-up.
  Tray menu activation remains unverified. No-activate show paired with explicit
  rendering visibility preserved foreground in the immediate follow-up test;
  complete display/suspend lifecycle still gates final native adoption.
- Real 150/200% and mixed DPI, physical display removal and suspend/resume are
  still gated on corresponding device evidence. Resizing a 96-DPI window to
  128/192/256 pixels is not a DPI test. Full RTL/accessibility and real OS reduced
  motion remain unverified.
- Coucou source snapshots and complete license notices are retained at the pinned
  revision in the report. No Coucou implementation was imported into the probe and
  no protected character/media was copied.

The animated companion implementation (N1b) waits for closure of its N0
asset/render/native gates. The authorized independent N1a main shell and native
login plumbing can proceed without shipping rejected character art. This is not
closure of the full N0 or Windows acceptance gate.
Unresolved choices must not become default libraries, fake passing checks or
speculative product interfaces.

### Identity acceptance ownership

Windows capability acceptance is NYLRA-owned. Linux identity/provider/session
acceptance is shadows-backend-owned. Joint login acceptance follows only after
both sides run together. NYLRA owns system-browser launch, a listener bound only
to IPv4 127.0.0.1 with an ephemeral port and `/oidc-return`, a locally generated
S256 return verifier, OS-protected opaque-session persistence, restart validation
and logout behavior. The verifier and session handle must stay out of webview IPC.
Backend identity validation, ticket validity/replay, account/device mapping and
session revocation remain in shadows-backend.

Native fixtures prove local plumbing only. The backend's current proposed service
interfaces are not an exported wire schema. Do not adapt the earlier direct-OIDC
B0 fixture into a competing protocol. Enable network authentication only after
consuming the backend-owned versioned contract and matching fixtures. On restart,
stored bytes indicate local material, not authentication; on logout, local clearing
does not establish backend/provider revocation.

## 4. Windows architecture and interaction

Retain React/TypeScript/Vite presentation and Tauri Rust platform integration.
Provide a companion surface plus a main topic/source/settings surface. Give each
window minimal capabilities. Generated remote text never becomes privileged HTML
or a native command. A confirmation view renders trusted proposal data independently
of the generated explanation and reports queued/accepted/completed separately.

Feature state/actions use a data layer for server projections and narrow platform
wrappers for native calls. Do not duplicate server authorization in a UI store.
Use ordinary local state for simple view interaction; add a state-machine library
only if the measured transition complexity benefits. Select server-cache/UI utility
libraries at N0/N2 against actual reconnect and accessibility needs, not by inventory.

Cloud chat goes to shadows-backend; local Shadows access is presentation/navigation.
The daemon owns the cloud connector. Closing NYLRA must not close that connector.
Workspace/account switches isolate cached evidence and pending input. Reconnect
resumes through J1, with explicit resnapshot when needed; a cached view is not fresh.

## 5. Scope of our own modules

Own AYLUL visual-state mapping, native window behavior, source/freshness presentation,
topic navigation and trusted confirmation interaction. Use maintained libraries for
rendering, routing/cache when justified, protocol generation and native plugins.
No custom transport stack, model SDK, ORM or queue belongs in the desktop app.
Do not publish a custom component framework before another actual consumer exists.
Use the shared source-contract convention for behavior-bearing units.

## 6. Voice, mobile and Production

Text remains the fallback. Voice acceptance proves permission denial, interruption,
capture stopped, playback stopped and no stale audio after topic switch. STT and TTS
remain separate from reasoning; the client owns capture/playback, not cloud dialogue.
Voice-only human approval remains gated by Shadows §24.6.

Flutter follows the Windows journey using the same versioned protocol and fixtures.
Android/iOS delivery order and available physical devices are decided at the mobile
gate, not assumed here. Native lock-screen/background limitations need per-platform
evidence; a WebView preview is not phone acceptance. No forced TS/Dart code sharing.

Production adds scoped incident cards with source time, facts versus hypotheses,
proposed remedy, cost assumptions, required authority and post-action result.
The companion never independently scales AWS resources. Teams, multiple instances,
advanced memory, richer accessories, external integrations and enterprise hosting
remain in the Vision inventory and need their own complete slices.

## 7. Acceptance

The first integrated Windows journey: open AYLUL, sign in, select a permitted topic,
read a sourced explanation from current Shadows work, restart, then reopen it with
correct history/freshness. Separate tests cover stale data, revoked link, interrupted
stream and account switch. A native Windows trial must include display/focus behavior.
Assessment/approval claims wait for backend B4 and real Shadows enforcement.

Research: [Coucou and library record](../../evidence/2026-10-10-coucou-and-library-research.md).
Backend: [delivery spec](../../../../shadows-backend/docs/superpowers/specs/2026-10-10-backend-delivery-design.md).

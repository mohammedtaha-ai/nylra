# NYLRA delivery design

Date: 2026-10-10. Status: initial specification requested by Mohammed.
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

Preserve both original root PNGs. Use the Companion Character Reference Board as
the proposed small-size silhouette and the Shadow Companion Design Sheet for richer
detail. Evaluate both at the same real display sizes before finalizing the choice.
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
pin dependencies and record rejected alternatives. Delete disposable probe sources
after their evidence is recorded, retaining the source revision where applicable.

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

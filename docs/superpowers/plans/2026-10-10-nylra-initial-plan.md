# NYLRA Initial Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for inline execution,
> or superpowers:subagent-driven-development when delegation is explicitly selected.

**Goal:** Deliver AYLUL on Windows connected to real Shadows through the cloud,
then complete voice, mobile continuity and operational incident experiences.
**Architecture:** React/Tauri desktop and later Flutter mobile; cloud dialogue and
project authority remain in their existing owners.
**Tech Stack:** React/TypeScript/Vite/Tauri 2, renderer decided by N0; Flutter later.
**Spec:** [NYLRA delivery](../specs/2026-10-10-nylra-delivery-design.md).
**Status:** Initial plan, not executed. Windows-first choice confirmed by the user.

## Global constraints

- N0 experiments decide libraries/assets; revise this plan before dependent work.
- Preserve original PNGs; create original production assets with explicit provenance.
- Do not copy Coucou's protected character, sounds or artwork.
- Do not make client state authoritative for project decisions or AWS operations.
- Native device evidence is distinct from browser previews and fake protocol tests.
- Paths below are planned; no placeholder source/contract folders are required.

## Review focus

1. Mixed DPI or unplugged monitor must not strand an invisible window (N1).
2. A hidden companion must not keep unnecessary frame work running (N0/N1).
3. Account switch must clear the previous account's evidence and input (N2).
4. A late stream response must not overwrite the newly selected topic (N2).
5. A changed proposal must not reuse an earlier confirmation (N3).

## Coordination

[Backend plan](../../../../shadows-backend/docs/superpowers/plans/2026-10-10-backend-initial-plan.md)
owns J1 wire artifacts and names J0-J3. N0/B0 can proceed independently. N1 is a
local shell; N2 waits for J1/B3 and real Shadows context for J2 acceptance. N3 waits
for B4 and actual Shadows §24.6 enforcement before J3 acceptance. Never hide that
dependency by making NYLRA approve locally.

### N0: AYLUL and native capability experiments

**Inputs:** root reference-board and design-sheet PNGs.
**Output:** `docs/evidence/<run-date>-aylul-windows-probes.md`; amend this plan/spec.
**Temporary artifacts:** isolated asset/render/native trial, not product scaffolding.

- [ ] Preserve originals and compare the two silhouettes at 64/96/128 logical pixels.
- [ ] Prepare representative original transparent idle/listening/blocked states
  with equal pivot/scale; inspect alpha edges on light and dark backgrounds.
- [ ] Compare browser raster animation with PixiJS only if layered animation needs
  it; evaluate one Rive interaction if a rig remains a credible alternative.
- [ ] Measure idle/active/hidden CPU, frame-time and memory on the same machine;
  establish acceptance budgets in the evidence before accepting the renderer.
- [ ] Prove transparent Tauri window, drag, restricted click-through, tray, single
  instance, shortcut, focus and suspend/resume. Test 100/150/200 percent DPI and
  display removal with main/companion surfaces.
- [ ] Review exact Coucou source/license before any reuse; record borrowed code
  provenance/notices separately from original AYLUL art. No blanket fork.
- [ ] Select dependencies and asset pipeline from evidence, pin versions, replace
  later task assumptions and record any unavailable physical-device scenario.

**Exit:** accepted asset/render/native approach and revised tasks. A static board
preview cannot close animation or native-window acceptance.

### N1: Working Windows companion shell

**Intended files:** `apps/desktop/package.json`, `apps/desktop/src/app/`,
`apps/desktop/src/features/companion/`, `apps/desktop/src/platform/`,
`apps/desktop/src-tauri/src/{lib,main}.rs`, native `windows/` and `commands/`,
`apps/desktop/src-tauri/capabilities/`, `assets/aylul/manifest.json`,
`apps/desktop/tests/companion-lifecycle.test.ts`.
**Consumes:** N0 choices. **Produces:** companion/main surfaces and pure visual
state transitions; exact interface names are fixed in N0's amended plan.

- [ ] Write failures for hidden animation, rapid drag/click, missing display,
  stale visual event, keyboard navigation and reduced motion.
- [ ] Implement composition and the minimal native/window wrappers using selected
  official plugins first. Scope capabilities per surface.
- [ ] Produce the nine original states with a manifest; missing assets fail visibly
  or fall back to an explicit neutral state, never an unrelated success animation.
- [ ] Verify no focus stealing during ordinary notifications; main panel remains
  keyboard-accessible without the companion.
- [ ] Run Windows acceptance, source-contract checks and scoped tests; record and commit.

### N2: Real topic conversation and sources

**Intended files:** `apps/desktop/src/features/{connections,conversations,sources}/`,
`apps/desktop/src/data/`, `apps/desktop/src/api/generated/`,
`apps/desktop/src-tauri/src/local_shadows/`,
`apps/desktop/tests/topic-reconnect.test.ts`, `protocol-fixtures/`.
**Consumes:** J1 and B1-B3. **Produces:** J2 integrated Windows journey.

- [ ] Generate the client from pinned J1 artifacts; consume shared conformance
  examples without importing backend source.
- [ ] Test topic/account switches during a stream, duplicate/out-of-order events,
  revoked links, cursor expiry, dropped connection and restored cached sources.
- [ ] Implement selected-project navigation, durable topic view, source/version
  display and explicit offline/freshness state. Decide cache/query libraries from
  these tests rather than adding an unused global store.
- [ ] Keep local Shadows navigation separate from cloud chat; verify closing NYLRA
  leaves the daemon-owned connector alive.
- [ ] Run direct Planner conversation -> NYLRA explanation with actual sources,
  provider stream, restart and recovery. Record J2 only after the real path works.
- [ ] Update contracts/evidence and commit this complete slice.

### N3: Assessment and trusted confirmation

**Intended files:** `apps/desktop/src/features/confirmations/`,
`apps/desktop/tests/confirmation-basis.test.ts`.
**Consumes:** B4 and Shadows §24.6. **Produces:** J3 user-confirmed owner outcome.

- [ ] Test changed proposal while the panel is open, expired/revoked authority,
  repeated clicks, two devices and model text claiming that an action succeeded.
- [ ] Render trusted operation/proposal basis outside generated response markup;
  bind explicit user action to that exact basis using J1.
- [ ] Display queued, delivered, accepted, rejected and completed according to
  owner evidence. Assessment requests never silently become adoption requests.
- [ ] Verify real owner records and refused stale submissions; update contracts,
  record the native trial and commit.

### N4: Voice and attention

**Intended files:** `apps/desktop/src/platform/audio/`,
`apps/desktop/src/features/conversations/`, native `notifications/` as needed.
**Consumes:** B5, N2. **Produces:** cancellable voice with text fallback.

- [ ] First probe actual microphone/playback/provider behavior and choose maintained
  libraries against permission denial, interruption and device changes.
- [ ] Amend this task with selected library/version and exact commands before code.
- [ ] Test topic switch during speech, muted output, denied capture, sleep/resume,
  duplicate notifications and quiet hours. No stale playback after cancellation.
- [ ] Map listening to active capture and speaking to playback; never infer human
  confirmation from a transcript. Run actual Windows voice acceptance and commit.

## Later slices retained in the full plan

| Slice | Prerequisite | Intended paths | Acceptance exit |
| --- | --- | --- | --- |
| N5 Mobile capability proof | Windows J2, B6 protocol readiness | `apps/mobile/`, evidence | Select physical Android/iOS targets, prove login, stream/reconnect, notifications and audio |
| N6 Mobile product journey | N5 selections, J3 for confirmation | Flutter `lib/ui/`, `lib/data/`, `integration_test/` | Same topic across desktop/phone, scoped cache, stale refusal, real lock-screen/background limits |
| N7 Production companion | Backend B8/B9 and Shadows §17.12 | New incident feature only with first user | Sourced pressure alert, remedy explanation, confirmed owner outcome and measured result |
| N8 Team and richer presence | Rust team owner, B7 | Existing connection/source views plus required feature units | Workspace isolation, multiple incidents, original accessories, discoverable attention controls |

Advanced memory, more channels, non-Shadows integrations and enterprise use stay
in Vision. Expand later slices only after their preceding evidence exists, keeping
the full direction without speculative module scaffolding.

## Verification and amendment

N0 records the exact package-manager commands for typecheck, test, production build
and native checks for selected versions. Add native Windows acceptance steps to
the task they prove. UI tests alone do not establish tray/audio/background behavior.
Every behavior task follows failing test -> implementation -> passing checks ->
contract/evidence update -> scoped commit. Artifact-only steps use visual inspection
and manifest validation rather than artificial implementation-mirroring tests.

A failed probe updates the spec, dependency decision and affected tasks in both
plans. Maintain one chosen path, not a parallel rejected renderer or client engine.
No implementation or successful capability trial is claimed by writing this plan.

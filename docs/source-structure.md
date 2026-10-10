# NYLRA source organization

Date: 2026-10-10. Status: prepared design for review; no source is scaffolded.
This file owns client source placement. [Vision](../Vision.md) owns experience;
the [shared architecture](../../shadows-backend/docs/architecture.md) owns system
boundaries. Listed paths are future destinations, not claims of existing code.

## Selected approach

Keep desktop and mobile applications in one repository, each with its normal
toolchain. Share protocol definitions, fixtures and asset specifications across
languages; do not force Dart to reuse TypeScript application logic. Neither client
owns project rules or cloud NYLRA orchestration.

A single cross-platform UI would contradict the chosen React/Tauri and Flutter
direction. Separate repositories for these two clients would add coordination
without removing their shared product/protocol changes. This organization keeps
each build independent while allowing one review to update both consumers.

## Intended layout

```text
apps/
  desktop/
    src/
      app/                       composition, navigation and application lifecycle
      features/
        conversations/           topic dialogue presentation
        sources/                 evidence and freshness presentation
        confirmations/           deliberate confirmation interaction
        connections/             project-link presentation
        preferences/             user settings presentation
        companion/               AYLUL presence
      api/generated/             generated cloud wire client/types
      data/                      scoped client data access and cache
      platform/                  typed Tauri invocation wrappers
      ui/                        reusable presentation primitives
    src-tauri/
      src/
        lib.rs                   native composition
        main.rs                  desktop entry point
        commands/                typed native operation boundary
        local_shadows/           local presentation/navigation integration
        windows/                 window lifecycle
        notifications/           native notification integration
        audio/                   native capture/playback integration if needed
      capabilities/              minimal permissions per window
    tests/                       desktop journeys
  mobile/
    lib/
      main.dart                  mobile entry point
      app/                       dependency composition and routing
      ui/
        conversations/           views and view models
        sources/                 evidence display
        confirmations/           deliberate confirmation interaction
        connections/             project-link presentation
        preferences/             user settings presentation
        core/                    reusable visual primitives
      data/
        repositories/            scoped client view/cache coordination
        services/                remote API access
        generated/               generated cloud wire client/types
      platform/                  mobile notification/audio integration
    test/                        unit and widget checks
    integration_test/            mobile journeys
assets/                          canonical character/media source assets
protocol-fixtures/               versioned consumer conformance examples
docs/
  codebase/README.md             actual ownership map when source exists
  evidence/                     dated desktop/mobile observations
```

Only create paths required by an implemented journey. Files inside a feature are
named for the work they do, not forced into a fixed number of layers. Native
Android/iOS and build configuration follow the tool-generated Flutter layout.
Each app keeps its own dependencies and lockfile. Asset packaging copies required
formats into build inputs; one asset manifest records origin, version and license.

## Client boundaries

Desktop components call feature state/actions, which use the data layer or narrow
platform wrappers. They do not import a database client, model SDK or raw Tauri
commands throughout the UI. Tauri Rust owns native operations, not a second NYLRA
engine. Local Shadows navigation cannot become an alternate approval route.
Remote content is displayed as data, never privileged application code. Scope
capabilities to the window that needs them; an animated companion window should
not inherit every permission of the confirmation surface.

Mobile views observe view models; view models use repositories, which coordinate
API services and client caches. A repository is authoritative for the displayed
client projection only, never for accepting a project decision. Add a separate
use-case/domain layer only when actual client logic warrants it. Do not duplicate
server authorization or require a specific state-management package in this design.

Both clients distinguish draft, queued, accepted and completed outcomes from the
owner. Offline caches retain source scope/version/freshness. Account/workspace
switches clear or partition caches; revocation invalidates derived views. Navigation
to a new workspace cannot leave the previous workspace's sources in the composer.

## Protocols, contracts and tests

The backend owns its wire schema. Clients pin a versioned generated artifact and
must not reach into sibling TypeScript source. Desktop local Shadows integration
uses Shadows' own protocol, not the cloud client's types. Generated DTOs do not
become shared domain classes; map to presentation state only where useful.

Use the [source contract convention](../../shadows-backend/docs/contracts/README.md)
for behavior-bearing modules: conversation state, confirmation interaction, cache
invalidation and native command boundaries are examples. Pure rendering widgets
are covered by their owning feature contract when they have no independent rule.
Keep contracts beside actual source; do not fill them from this directory plan.

Shared conformance fixtures describe observable wire behavior, not shared UI code.
Both clients should exercise source attribution, expired proposals, identical retry
outcomes, workspace switching and reconnect against those fixtures. End-to-end tests
must also reach the real owner; fake replies cannot prove approval enforcement.
Voice/background delivery and cross-device continuity require real-device evidence.

## Research basis

Flutter recommends UI/data separation, views/view models and repositories/services;
an extra domain layer is conditional. This design adopts those responsibilities
without deciding a state-management library.
[Flutter recommendations](https://docs.flutter.dev/app-architecture/recommendations).

Tauri's conventional layout separates frontend source from `src-tauri`, and its
capability system scopes native access by window/webview. We retain that split.
[Tauri layout](https://v2.tauri.app/start/project-structure/),
[Tauri capabilities](https://v2.tauri.app/security/capabilities/).
Checked 2026-10-10. The feature names above are our product-specific choices.

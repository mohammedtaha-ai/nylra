# NYLRA - Agent Instructions

Read [README.md](README.md), [Vision.md](Vision.md), and the
[shared architecture](../shadows-backend/docs/architecture.md) before code.
Read [source structure](docs/source-structure.md) for the prepared client layout
and the [contract convention](../shadows-backend/docs/contracts/README.md) before
adding source. Proposed paths are not an existing code map.

- This repository owns desktop and mobile clients. Shared cloud domain logic
  belongs to `shadows-backend`; local execution belongs to Shadows.
- Use TypeScript/React for desktop presentation, Rust/Tauri for desktop platform
  integration, and Flutter/Dart for mobile. Do not silently change that direction.
- Keep interfaces free of project domain rules. Invoke the owning service.
- Keep desktop local navigation distinct from cloud-mediated NYLRA dialogue,
  assessment, and confirmation. The cloud link lives in AYLUL desktop's Node
  sidecar, not in its UI.
- Preserve source scope and version in explanations. Personal preferences do
  not grant authority. Never treat model output as human confirmation.
- Follow Shadows §1.7 for personal/team authority and §24.6 for confirmation.
  Voice prepares a proposal; it cannot manufacture approval evidence. Show queued,
  accepted and completed states separately using the owner's actual outcomes.
- Each source module has one named job. Use the
  [source contract template](../shadows-backend/docs/contracts/TEMPLATE.yaml)
  to describe inspected behavior and keep contracts current with source changes.
- Obligations name inspected tests or explicitly missing evidence. Gaps name
  stable symbols. Refer to externally owned types instead of copying them.
- Maintain a code map when source exists. Do not create fictional modules,
  placeholder contracts, or duplicated architecture owners.
- Explain changes before editing. Report the exact verification performed;
  real voice, notification, and device-continuity claims need real-device evidence.
- Record unresolved decisions with a closing trigger in their owner document.
- A local documentation request does not authorize commit, push, or deployment.

## Working together

Two people build this repository in parallel (decided 2026-10-13).

- **One short branch per task,** started from the latest `main`. Open a PR,
  merge it, delete the branch. No branch stays open for days, and no second
  long-lived branch runs beside `main`.
- **Separate folders.** The Flutter app lives in `apps/mobile` and AYLUL's art
  in `assets/aylul`; the desktop app lives in `apps/desktop`. A change outside
  your folder goes in its own small PR.
- **The contract is the only meeting point.** Both apps are built against
  `shadows-backend/api/nylra-v1.openapi.json`. Generate Dart or TypeScript from
  it and never edit a copy; a field an app needs is added by a PR to the
  backend's TypeBox source first.

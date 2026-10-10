# NYLRA

Cloud-backed human liaison with a desktop companion and a mobile application.
AYLUL is its companion character.

**Status:** Product vision and agreements recorded. This repository currently
contains documentation and character reference images, not an implemented app.

## Start here

| Document | Owns |
| --- | --- |
| [Vision](Vision.md) | The complete companion experience and future capabilities |
| [Shared architecture](../shadows-backend/docs/architecture.md) | Languages, hosting, integration paths, scoped context, and authority boundaries |
| [Agent instructions](AGENTS.md) | Source ownership, contracts, and verification workflow |
| [Source contract template](../shadows-backend/docs/contracts/TEMPLATE.yaml) | The evidence-based structure for describing an implemented source module |

The desktop direction is a TypeScript/React interface with Rust integration
inside Tauri 2. The mobile direction is Flutter/Dart. NYLRA's cloud logic belongs
to the shared TypeScript/Node.js application in `shadows-backend`.

Linking is optional per Shadows project. NYLRA follows the current work and
intervention topics, retrieves permitted sources, and explains them through its
own selected model. It does not replicate complete Planner histories.

Sibling links assume repositories named `nylra`, `shadows-backend`, and
`shadows` are checked out beside each other.

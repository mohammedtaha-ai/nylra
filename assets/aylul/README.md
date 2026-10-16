# AYLUL appearance sources

The current Canvas companion is extracted from root `ayl.html` into
`apps/desktop/src/features/companion/`. Its design and implementation plan live in
`docs/character/`. The renderer does not load the historical PNGs.

At the user's request on 2026-10-16, the legacy PNG expressions, animation packs,
candidate images and reference board were moved to the local directory
`archive/aylul-legacy-2026-10-16/`. Complete packs retain their metadata, previews
and generation tools. All moved files were verified by SHA-256. `/archive/` is
ignored by Git and is not distributed with a fresh checkout. Historical versions
remain recoverable from Git history; no history was rewritten.

Earlier evidence documents describe the assets at their original paths and dates.
Their PNG approval does not establish acceptance of the new Canvas renderer.

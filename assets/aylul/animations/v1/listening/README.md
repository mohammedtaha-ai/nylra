# AYLUL listening animation v1

This folder is the isolated, reviewable `listening` animation slice. It does not
contain runtime event bindings or product integration.

## Contents

- `frames/frame-000.png` through `frames/frame-023.png`: ordered transparent
  1254 x 1254 PNG frames.
- `still.png`: poster/still frame, copied byte-for-byte from the approved
  canonical listening image.
- `metadata.json`: frame order, hashes, playback timing, loop behavior, canvas,
  pivot, and motion assumptions.
- `preview/index.html`: dependency-free, local/test-only animation review page.

## Preserved appearance

The source is `assets/aylul/states/v1/listening.png` at SHA-256
`4d5de6d5009c7ef2b9d12a8fa0f20a3756055eb4394cfe8ce649807e9591b25f`.
It remains untouched. The animation keeps the approved RGB artwork, opaque
pixels, scale, silhouette, horizontal alignment, colors, proportions, glow
style, eyes, crystals, and details. The body remains stationary. The listening
rhythm is a soft double attention beat in existing bright eye pixels, followed
by a delayed head-crystal glow and a gentler pendant echo. Only alpha changes
inside tightly bounded, color-qualified source regions; no pixels are redrawn.

The fixed pivot is canvas coordinate `(627, 1102)`. Frames must not be trimmed
or independently centered; doing so would destroy the intended alignment.

## Local preview

Serve the repository root with any static file server, then open:

`/assets/aylul/animations/v1/listening/preview/`

For example, with Python installed:

```powershell
python -m http.server 8000 --bind 127.0.0.1
```

The preview offers exact 64, 96, and 128 px review sizes plus a 256 px detail
size, looping playback, pause/resume, and the still frame beside the animation.
When `prefers-reduced-motion: reduce` matches, playback is stopped by default and
can only be started explicitly. It is a review tool, not a runtime integration
surface.

## Scope and follow-up

Only `listening` is implemented here. Backend work, endpoint contracts,
Shadows integration, Planner logic, runtime event binding, and all other AYLUL
animation states remain intentionally pending until their owners and approvals
are ready.

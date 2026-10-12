# AYLUL listening animation v1

This folder is the isolated, reviewable `listening` animation slice. It does not
contain runtime event bindings or product integration.

## Contents

- `frames/frame-000.png` through `frames/frame-031.png`: ordered transparent
  1254 x 1254 PNG frames.
- `derived/masks/`: reusable feathered influence masks for the eyes, upper
  crystal, and hanging crystal.
- `tools/generate.py`: deterministic premultiplied-alpha mesh-warp generator.
- `still.png`: poster/still frame, copied byte-for-byte from the approved
  canonical listening image.
- `metadata.json`: frame order, hashes, playback timing, loop behavior, canvas,
  pivot, and motion assumptions.
- `preview/index.html`: dependency-free, local/test-only animation review page.

## Preserved appearance

The source is `assets/aylul/states/v1/listening.png` at SHA-256
`4d5de6d5009c7ef2b9d12a8fa0f20a3756055eb4394cfe8ce649807e9591b25f`.
It remains untouched. The animation keeps the approved rendered appearance,
scale, silhouette, canvas registration, colors, proportions, glow
style, eyes, crystals, and details. The listening rhythm now uses an attentive
body lean, coordinated eye focus, an independently lagged upper crystal, and a
damped hanging-crystal swing. Existing glow reacts softly after the movement.
Every frame is derived directly from the canonical source; no generative redraw
or alternate character design is used.

Because the source is flattened, the moving regions are continuous feathered
deformations rather than hard cutout layers. Premultiplied-alpha sampling avoids
holes, duplicate sprites, hard seams, and dark edge fringes. The small amount of
surrounding face/glow inside each feather is the documented compromise that keeps
the derived motion visually continuous.

The fixed pivot is canvas coordinate `(627, 1102)`. Frames must not be trimmed
or independently centered; doing so would destroy the intended alignment.

## Local preview

Serve the repository root with any static file server, then open:

`/assets/aylul/animations/v1/listening/preview/`

For example, with Python installed:

```powershell
python -m http.server 8000 --bind 127.0.0.1
```

The preview offers exact 64, 96, 128, and 256 px review sizes, frame preloading,
looping playback, pause/resume, and the still frame beside the animation.
When `prefers-reduced-motion: reduce` matches, playback is stopped by default and
can only be started explicitly. It is a review tool, not a runtime integration
surface.

## Scope and follow-up

Only `listening` is implemented here. Backend work, endpoint contracts,
Shadows integration, Planner logic, runtime event binding, and all other AYLUL
animation states remain intentionally pending until their owners and approvals
are ready.

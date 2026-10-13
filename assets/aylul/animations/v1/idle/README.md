# AYLUL idle animation v1

This folder contains the first approved development slice for AYLUL animation:
idle only. It is an asset pack and local review surface, not product runtime
integration.

`still.png` and `frames/frame-000.png` are byte-identical copies of the approved
canonical `assets/aylul/states/v1/idle.png`. The remaining numbered PNGs retain
the same 1254x1254 transparent canvas and copy the canonical decoded pixels at
integer vertical offsets. No frame is redrawn, recolored, rescaled, interpolated,
or trimmed. `metadata.json` owns frame order, hashes, playback, canvas, and pivot
assumptions.

## Local preview

From the repository root, run:

```powershell
python -m http.server 8000 --bind 127.0.0.1
```

Then open
`http://127.0.0.1:8000/assets/aylul/animations/v1/idle/preview/`.
The dependency-free page shows looping playback, the still frame, and
small/medium/large display sizes. It pauses frame scheduling while the page is
hidden. Controls and labels are test-only and do not emit product events.

## Scope and next trigger

The approved canonical idle, listening, and blocked images remain untouched.
No candidate expression was promoted or modified. Happy, listening, speaking,
thinking, working, success, blocked, and sleeping animation work remains pending.
Runtime/event binding, renderer selection, and native performance acceptance are
deferred until this idle motion is reviewed and the owning N1b gate authorizes the
next slice.

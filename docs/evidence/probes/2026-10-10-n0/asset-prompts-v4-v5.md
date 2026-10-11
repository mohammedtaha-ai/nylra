# AYLUL continuation prompt provenance — 2026-10-11

Built-in image_gen; transparent_background=true on all four calls. Internal model
version was not exposed. Original v3 and root reference board inspected before edits.
No CLI API keys, Coucou art or third-party character assets used. Generated files
copied intact into native/ui; originals remain under Codex generated_images.

## Idle v4 (not selected)

Input: native/ui/idle-v3.png. Output: exec-0322cb7a-7789-4941-8edd-d0e02451751d.png,
copied to native/ui/idle-v4.png.

Exact prompt:

Use case: precise-object-edit and background-extraction. Edit target: the attached idle-v3 AYLUL character. Make ONE cleaned IDLE master sprite, as a transparent PNG. Preserve the exact beautiful original character design, camera, front-facing pose, dark plum hood geometry, rose-gold edging, two glowing oval purple eyes, top violet crystal and hanging right violet crystal, shading and 3D illustration style. Do not redesign or simplify the face or add accessories. Fix only edge cleanup, transparency and framing: eliminate all isolated colored noise, blue/magenta speckles and nearly-transparent pixels spread across the empty background. Retain the narrow intentional violet glow close to the crystals/hood. Uniformly scale the complete character plus its intentional glow to fit inside central 76 percent of a square canvas, centered, leaving every outer 12 percent border completely transparent (alpha exactly zero). Solid cloth/face/eyes fully opaque except antialiased perimeter; glow softly translucent but strictly bounded. No floor, no shadow plane, no checkerboard painted into image, no text, no other states, no particles. Keep original identity and visual detail. Output one single centered character, actual transparent alpha.

## Listening v4 (weak distinction)

Input: native/ui/idle-v3.png. Output: exec-5bdb9826-3fa0-43b9-9fe4-1cd73fa7d1b1.png,
copied to native/ui/listening-v4.png.

Exact prompt:

Precise-object-edit. Edit target is the attached original AYLUL idle-v3 sprite. Produce exactly one LISTENING expression variant of this same sprite, same transparent square canvas and exact body size/position. Strictly lock all hood, crystals, hanging earring, body, shading, camera and pose. Change ONLY the two eyes: make the pair visibly attentive, larger round-violet ovals with a slight upward focus, clearly distinguishable from the normal relaxed oval eyes at 64px. Do not add mouth, eyebrows, symbols, extra objects, rays, particles, wings or text. Preserve the exact existing silhouette, crystal and hood alignment; no enlargement/reframing/pose change. Keep true transparency and no alpha noise at the outer border. No background. The character must remain exactly the same recognizable cute mysterious 3D plum-hooded spirit as the reference, not a redesign. This is an expression trial, not permission to alter the cloth.

## Blocked v4

Input: native/ui/idle-v3-clean.png (inspected before edit).
Output: exec-ccb6bfda-8976-4347-a313-cf2a389f9416.png,
copied to native/ui/blocked-v4.png.

Exact prompt:

Use case: precise-object-edit. Input image is the approved design reference, AYLUL idle-v3-clean. Make exactly ONE BLOCKED / NEEDS ATTENTION expression, changing ONLY the glowing eyes. Preserve the original canvas, character scale, exact centered pose, silhouette, hood folds, rose-gold edging, face surface, both violet crystals and their positions, existing lighting and detail. Eyes become narrower violet shapes, gently worried/concerned, angled enough to distinguish from neutral idle at 64px; NOT menacing, angry or evil. No eyebrows, mouth, symbols, red warnings, exclamation marks, text, new accessories or particles. Black face outside the small eye edits stays unchanged. No zoom/reframe or body changes. Keep true transparent alpha, clean empty borders and soft local violet crystal glows. This is a tightly constrained eyes-only variant of the same beautiful 3D character, not a new drawing.

## Listening v5

Input: native/ui/idle-v3-clean.png.
Output: exec-58f92678-a22f-4843-a472-7504317839fd.png,
copied to native/ui/listening-v5.png.

Exact prompt:

Precise edit, original AYLUL listening trial v5. Keep the attached master character identical: same square transparent canvas, same hood, cloth outline, crystals, earring, face, front view, fixed scale and position. ONLY change the two violet eyes into unmistakably wide attentive ROUND eyes: make them about 45 percent wider than the relaxed original ovals, and slightly taller, so listening reads as awake and focused at 64 pixels. Both eyes should have clear lavender centers with small soft bright highlights; keep warmth and curiosity. Distinguish eye silhouette strongly, do not simply brighten the original ovals. Do not add earphones, eyebrows, mouth, symbols, exclamation marks, rays, particles or any accessories. Do not change lighting, hood folds, shape, trim or glows. No background, shadow plane or text, real alpha transparency. Empty outer 8 percent margin completely transparent. Preserve the original artwork's quality; this is an eyes-only expression change, not a new body.

## Deterministic cleanup

The user explicitly authorized Python alpha cleanup while preserving the artwork.
clean-alpha.py maps only alpha=1 to zero, retaining every RGB byte and alpha>=2.
Applied non-destructively to idle-v3, listening-v4, listening-v5 and blocked-v4;
each source and derived file is separate. Assertions and SHA-256 provenance are
recorded in artifacts/2026-10-11-release/*-clean-provenance.json.
This cleanup does not align regenerated bodies or repaint their light/glows.

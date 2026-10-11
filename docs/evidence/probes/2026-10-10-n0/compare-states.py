"""Read-only expression consistency diagnostics; no pixel export or image edits."""
from PIL import Image
import numpy as np
import json, sys

master=np.array(Image.open(sys.argv[1]).convert('RGBA'))
h,w=master.shape[:2]
outside_eye=np.ones((h,w),dtype=bool)
outside_eye[int(h*.52):int(h*.69),int(w*.35):int(w*.66)]=False
rows=[]
for path in sys.argv[2:]:
    candidate=np.array(Image.open(path).convert('RGBA'))
    if candidate.shape!=master.shape:
        rows.append(dict(file=path,same_canvas=False));continue
    core=(master[:,:,3]>=250)&(candidate[:,:,3]>=250)&outside_eye
    delta=np.max(np.abs(master[:,:,:3].astype(np.int16)-candidate[:,:,:3].astype(np.int16)),axis=2)
    alpha_changed=np.abs(master[:,:,3].astype(np.int16)-candidate[:,:,3].astype(np.int16))
    rows.append(dict(file=path,same_canvas=True,compared_solid_body_pixels=int(core.sum()),
        solid_body_rgb_difference_above8_fraction=float(np.count_nonzero(core&(delta>8))/core.sum()),
        solid_body_mean_rgb_max_channel_difference=float(delta[core].mean()),
        outside_eye_alpha_difference_above8_pixels=int(np.count_nonzero(outside_eye&(alpha_changed>8))),
        note='Diagnostic mask excludes the eye editing area; equal canvas does not establish identical body/lighting or an accepted pivot.'))
print(json.dumps(rows,indent=2))

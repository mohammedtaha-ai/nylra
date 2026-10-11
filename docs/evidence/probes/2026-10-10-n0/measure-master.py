"""Read-only sprite alpha measurements. Does not modify or export image pixels."""
from pathlib import Path
from PIL import Image
import hashlib, json, sys

def measure(path):
    path = Path(path)
    image = Image.open(path).convert('RGBA')
    alpha = image.getchannel('A')
    w, h = image.size
    histogram = alpha.histogram()
    edge = [alpha.getpixel((x, y)) for x in range(w) for y in (0, h-1)]
    edge += [alpha.getpixel((x, y)) for y in range(1, h-1) for x in (0, w-1)]
    margin = [(x,y) for y in range(h) for x in range(w) if x < w*.08 or x >= w*.92 or y < h*.08 or y >= h*.92]
    raw_box = alpha.getbbox()
    visible_box = alpha.point(lambda a: 255 if a > 32 else 0).getbbox()
    return dict(file=str(path),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),size=[w,h],
        raw_alpha_bbox=raw_box,alpha_above_32_bbox=visible_box,
        fully_transparent_pixels=histogram[0],opaque_pixels=histogram[255],
        alpha_at_least250_pixels=sum(histogram[250:]),alpha_2_to32_pixels=sum(histogram[2:33]),
        edge_nonzero=sum(a>0 for a in edge),edge_max_alpha=max(edge),
        edge_above32=sum(a>32 for a in edge),
        outer8percent_nonzero=sum(alpha.getpixel(p)>0 for p in margin),
        outer8percent_above32=sum(alpha.getpixel(p)>32 for p in margin),
        strict_edge_pass=not any(edge),
        note='Alpha >32 is a diagnostic only; it does not replace the original zero-alpha padding criterion.')

print(json.dumps([measure(p) for p in sys.argv[1:]],indent=2))

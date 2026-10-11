"""NON-PRODUCT: read-only PNG alpha/geometry measurements; never writes images."""
from PIL import Image
from pathlib import Path
import hashlib, json
root=Path(__file__).resolve().parents[4]
paths=[root/'AYLUL Companion Character Reference Board.png',root/'AYLUL Shadow Companion Design Sheet.png',Path(__file__).parent/'native/ui/trial-atlas.png',Path(__file__).parent/'native/ui/trial-atlas-v2.png']
out=[]
for p in paths:
    if not p.exists():
        out.append(dict(path=str(p.relative_to(root)),status='missing; alternative board intentionally removed by owner on 2026-10-11; historical measurements remain'))
        continue
    im=Image.open(p).convert('RGBA');a=im.getchannel('A');hist=a.histogram()
    item=dict(path=str(p.relative_to(root)),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),size=im.size,alpha_zero=hist[0],alpha_partial=sum(hist[1:255]),alpha_opaque=hist[255],bbox=a.getbbox())
    if 'atlas' in p.name:
        item['cells']=[]
        for j in range(3):
            cell=im.crop((j*im.width//3,0,(j+1)*im.width//3,im.height));ca=cell.getchannel('A');box=ca.getbbox()
            item['cells'].append(dict(state=['idle','listening','blocked'][j],alpha_bbox=box,alpha_bbox_over_32=ca.point(lambda x:255 if x>32 else 0).getbbox(),bottom_pivot=[cell.width/2,cell.height],edge_alpha_nonzero=sum(1 for x in range(cell.width) if ca.getpixel((x,0)) or ca.getpixel((x,cell.height-1)))))
    out.append(item)
print(json.dumps(out,indent=2))

"""User-authorized alpha=1 cleanup only. Preserve RGB, geometry and alpha>=2."""
from pathlib import Path
from PIL import Image
import hashlib, json, sys

source, target = map(Path, sys.argv[1:3])
if source.resolve() == target.resolve() or target.exists():
    raise SystemExit('Refuse source overwrite or existing destination')
original_hash = hashlib.sha256(source.read_bytes()).hexdigest()
original = Image.open(source).convert('RGBA')
cleaned = original.copy()
alpha = original.getchannel('A')
changed = alpha.histogram()[1]
cleaned.putalpha(alpha.point(lambda a: 0 if a == 1 else a))
cleaned.save(target)
output = Image.open(target).convert('RGBA')
before, after = original.tobytes(), output.tobytes()
assert original.size == output.size
assert all(before[i:i+3] == after[i:i+3] for i in range(0, len(before), 4))
assert all(after[i] == (0 if before[i] == 1 else before[i]) for i in range(3, len(before), 4))
assert hashlib.sha256(source.read_bytes()).hexdigest() == original_hash
print(json.dumps(dict(source=str(source),target=str(target),source_sha256=original_hash,
    target_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),alpha1_pixels_removed=changed,
    rgb_exactly_preserved=True,alpha_at_least2_exactly_preserved=True,source_unchanged=True),indent=2))

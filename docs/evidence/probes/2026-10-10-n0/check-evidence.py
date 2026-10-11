"""NON-PRODUCT syntax, manifest, sample completeness and local-link checks."""
import ast,csv,hashlib,json,re,subprocess,tempfile
from pathlib import Path
probe=Path(__file__).resolve().parent;root=probe.parents[3]
for p in probe.rglob('*.json'):
    if 'target' not in p.parts:json.loads(p.read_text(encoding='utf-8-sig'))
for p in (probe/'artifacts').rglob('*.jsonl'):
    for l in p.read_text(encoding='utf-8-sig').splitlines():json.loads(l)
for p in probe.glob('*.py'):ast.parse(p.read_text(encoding='utf-8-sig'),filename=str(p))
manifest=json.loads((probe/'asset-manifest.json').read_text())
for a in manifest['atlases']:assert hashlib.sha256((probe/a['path']).read_bytes()).hexdigest()==a['sha256']
for p in [* (probe/'native/ui').glob('*.html'),probe/'artifacts/initial-ui-index.html',probe/'artifacts/canvas-ui-index.html']:
    scripts=re.findall(r'<script>(.*?)</script>',p.read_text(),re.S)
    for script in scripts:
        with tempfile.TemporaryDirectory(prefix='nylra-n0-js-') as d:
            f=Path(d)/'script.js';f.write_text(script,encoding='utf-8');subprocess.run(['node','--check',str(f)],check=True)
for name in ['performance-initial.csv','performance-canvas.csv','performance.csv']:
    rows=list(csv.DictReader((probe/'artifacts'/name).open(encoding='utf-8-sig')))
    for stage in ['idle','active','hidden','reshown','reduced']:assert sum(r['Stage']==stage for r in rows)==10,(name,stage)
for name in ['performance-canvas.csv','performance-css.csv']:
    rows=list(csv.DictReader((probe/'artifacts/2026-10-11'/name).open(encoding='utf-8-sig')))
    for stage in ['idle','active','hidden','reshown','reduced']:assert sum(r['Stage']==stage for r in rows)==5,(name,stage)
    for r in rows:
        assert r['MainMinimized']=='False' and r['MainSize']=='PhysicalSize { width: 640, height: 480 }' and r['CompanionSize']=='PhysicalSize { width: 128, height: 128 }' and float(r['Scale'])==1
docs=[root/'docs/evidence/2026-10-10-aylul-windows-probes.md',root/'docs/evidence/2026-10-11-aylul-windows-probes.md',root/'docs/superpowers/specs/2026-10-10-nylra-delivery-design.md',root/'docs/superpowers/plans/2026-10-10-nylra-initial-plan.md',probe/'README.md']
for p in docs:
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text(encoding='utf-8-sig')):
        target=target.strip('<>').split('#')[0]
        if not target or re.match(r'^[a-z]+:',target):continue
        assert (p.parent/target).exists(),(str(p),target)
print('PASS: JSON/JSONL, Python/embedded JS syntax, asset hashes, 200 complete measurement samples, matched-window conditions, document local links. This does not pass N0 capability gates.')

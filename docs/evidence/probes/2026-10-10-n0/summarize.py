"""NON-PRODUCT: aggregate retained measurements without inferring acceptance."""
import csv,json,statistics
from pathlib import Path
p=Path(__file__).parent/'artifacts'
result={}
for name in ['performance-initial.csv','performance-canvas.csv','performance.csv']:
    f=p/name
    if not f.exists():continue
    rows=list(csv.DictReader(f.open(encoding='utf-8-sig')))
    stages={}
    for stage in dict.fromkeys(r['Stage'] for r in rows):
        a=[r for r in rows if r['Stage']==stage];cpu=[float(r['CPUOneCorePercent']) for r in a]
        stages[stage]=dict(samples=len(a),mean_cpu_one_core=statistics.mean(cpu),median_cpu_one_core=statistics.median(cpu),max_cpu_one_core=max(cpu),mean_machine_cpu=statistics.mean(cpu)/12,max_working_set_mib=max(float(r['WorkingSetMiB']) for r in a),max_private_mib=max(float(r['PrivateMiB']) for r in a))
    result[name]=stages
for name in ['runtime-initial.jsonl','runtime-canvas.jsonl','runtime-css.jsonl']:
    f=p/name
    if not f.exists():continue
    samples=[]
    for line in f.read_text(encoding='utf-8-sig').splitlines():
        r=json.loads(line)
        if r.get('window')=='companion' and r.get('event')=='metrics' and r.get('value',{}).get('kind')=='sample':samples.append(r['value'])
    active=[s for s in samples if s['mode']=='active' and s['frames']>=290]
    result[name]=dict(active_full_bins=len(active),active_p95_max_ms=max((s['p95'] for s in active),default=None),active_interval_max_ms=max((s['max'] for s in active),default=None),explicit_hidden_samples=[s for s in samples if s.get('surfaceVisible') is False],reduced_samples=[s for s in samples if s['mode']=='reduced'])
print(json.dumps(result,indent=2))

// Checks new evidence/links and real source contract destinations. Install YAML
// in a git-ignored verification directory, never as a product dependency.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'../../../..');
const yaml=require(path.join(root,'.superpowers/validation/node_modules/yaml'));
const native=path.join(root,'apps/desktop/src-tauri/src');
const contracts=['apps/desktop/src/app/contract.yaml','apps/desktop/src/platform/contract.yaml',...['windows','commands','native_login'].map(n=>`apps/desktop/src-tauri/src/${n}/contract.yaml`),'docs/evidence/probes/2026-10-10-n0/native/contract.yaml'];
for(const file of contracts){const c=yaml.parse(fs.readFileSync(path.join(root,file),'utf8'));assert.ok(c.name&&c.responsibility);assert.ok(fs.existsSync(path.join(root,c.source)),file);}
for(const file of ['README.md','docs/source-structure.md','docs/evidence/2026-10-11-windows-shell-continuation.md','docs/superpowers/plans/2026-10-10-nylra-initial-plan.md','docs/superpowers/specs/2026-10-10-nylra-delivery-design.md']){
 const p=path.join(root,file);for(const match of fs.readFileSync(p,'utf8').matchAll(/\]\(([^)]+)\)/g)){const link=match[1].replace(/^<|>$/g,'').split('#')[0];if(!link||/^[a-z]+:/i.test(link))continue;assert.ok(fs.existsSync(path.resolve(path.dirname(p),link)),`${file}: ${link}`)}
}
const artifacts=path.join(__dirname,'artifacts');
for(const directory of ['2026-10-11-release','2026-10-11-dpi150','2026-10-11-dpi150-final','2026-10-11-dpi175']){
 for(const file of fs.readdirSync(path.join(artifacts,directory))){const p=path.join(artifacts,directory,file);if(file.endsWith('.json'))JSON.parse(fs.readFileSync(p,'utf8').replace(/^\uFEFF/,''));if(file.endsWith('.jsonl'))for(const line of fs.readFileSync(p,'utf8').trim().split(/\r?\n/))JSON.parse(line)}
}
const release=path.join(artifacts,'2026-10-11-release');
for(const directory of ['2026-10-11-dpi150-final','2026-10-11-dpi175']){
 const rows=JSON.parse(fs.readFileSync(path.join(artifacts,directory,'shell-observations.json'),'utf8'));
 for(const row of rows.filter(r=>'Passed' in r))assert.equal(row.Passed,true,`${directory}/${row.Scenario}`);
 const dpi=rows.find(r=>r.Scenario==='native-startup').Window.DPI;
 assert.equal(dpi,directory.includes('150')?144:168);
}
for(const directory of ['2026-10-11-release','2026-10-11-dpi150']){
 const rows=JSON.parse(fs.readFileSync(path.join(artifacts,directory,'focus-observations.json'),'utf8'));assert.equal(rows.length,20);assert.ok(rows.every(r=>r.Passed));
}
const menu=JSON.parse(fs.readFileSync(path.join(release,'tray-menu-observations.json'),'utf8'));assert.equal(menu.length,2);assert.ok(menu.every(r=>r.Passed));
console.log('PASS: six YAML/source contracts, current document links, new JSON/JSONL, final 150/175 DPI scenarios, 40 paired focus cycles, actual Open/Quit menu outcomes. No asset/renderer/joint-login acceptance inferred.');

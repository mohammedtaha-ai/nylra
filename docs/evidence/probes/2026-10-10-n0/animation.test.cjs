// Exercise the retained page's scheduler at 144Hz. A fake DOM/clock is needed
// because native hide does not change document.hidden in WebView2.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
function page() {
  let now=0,id=0,draws=0; const raf=new Map(), timers=new Map();
  const el=()=>({style:{},after(){},animate(){return {cancel(){}}},getContext(){return {setTransform(){},clearRect(){},drawImage(){draws++}}}});
  const nodes=new Map();
  const context=vm.createContext({location:{search:''},document:{hidden:false,body:{classList:{toggle(){}}},querySelector(s){if(!nodes.has(s))nodes.set(s,el());return nodes.get(s)},createElement:el,addEventListener(){}},Image:class{width=2172;height=724},innerWidth:128,innerHeight:128,devicePixelRatio:1,matchMedia:()=>({matches:false}),requestAnimationFrame(f){raf.set(++id,f);return id},cancelAnimationFrame(i){raf.delete(i)},setInterval(){return ++id},clearInterval(){},setTimeout(f,delay){timers.set(++id,{f,at:now+delay});return id},clearTimeout(i){timers.delete(i)},performance:{now:()=>now}});
  context.window=context;
  vm.runInContext(fs.readFileSync(__dirname+'/native/ui/index.html','utf8').match(/<script>([\s\S]*?)<\/script>/)[1],context);
  return {context,draws:()=>draws,step(){now+=1000/144;for(const [i,t] of [...timers])if(t.at<=now){timers.delete(i);t.f()}const pending=[...raf];raf.clear();for(const [,f]of pending)f(now)}};
}
test('active drawing is capped on a 144Hz display',()=>{const p=page();p.context.setMode('active');for(let i=0;i<144;i++)p.step();assert.ok(p.draws()<=31,`draws in one second: ${p.draws()}`);assert.ok(p.draws()>=20)});
test('native hide cancels frame work and show resumes it',()=>{const p=page();p.context.setMode('active');p.step();p.context.setSurfaceVisible(false);const before=p.draws();for(let i=0;i<144;i++)p.step();assert.equal(p.draws(),before);p.context.setSurfaceVisible(true);for(let i=0;i<144;i++)p.step();assert.ok(p.draws()>before)});
test('reduced motion stays static',()=>{const p=page();p.context.setMode('reduced');const before=p.draws();for(let i=0;i<144;i++)p.step();assert.equal(p.draws(),before)});

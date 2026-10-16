// Test-only entry: never imported by the application.
import React from 'react';
const source = '/src/features/companion/';
async function render(expression = 'idle', outfit = 'default') {
  try {
    const {renderCharacter} = await import(/* @vite-ignore */ source + 'renderer/character.ts');
    const {DEFAULT_SETTINGS} = await import(/* @vite-ignore */ source + 'catalog.ts');
    const canvas = document.createElement('canvas'); canvas.width = canvas.height = 256;
    const ctx = canvas.getContext('2d')!;
    const frame = {cx:128, cy:145, scale:0.7, lookX:0, lookY:0, tilt:0, time:0.25,
      earringAngle:0, blinkProgress:0, expression, outfit, mini:false, perchingHands:false,
      sleepingMarks:[{offset:0,size:12},{offset:0.33,size:16},{offset:0.66,size:20}], notificationPulse:0};
    renderCharacter(ctx, frame, DEFAULT_SETTINGS);
    const first = canvas.toDataURL();
    const pixels = ctx.getImageData(0,0,256,256).data;
    const visible = pixels.filter((v, i) => i % 4 === 3 && v > 0).length;
    const corner = pixels[3];
    ctx.clearRect(0,0,256,256); renderCharacter(ctx, frame, DEFAULT_SETTINGS);
    return {visible, corner, deterministic:first === canvas.toDataURL(), image:first, defaults:DEFAULT_SETTINGS};
  } catch (error) { return {error:String(error)}; }
}
Object.assign(window, {fixture:{render}});
if(new URLSearchParams(location.search).has('shell')){
 const callLog=document.createElement('pre');callLog.dataset.testid='fixture-ipc-calls';document.body.append(callLog);
 import('@tauri-apps/api/mocks').then(async({mockIPC})=>{
  mockIPC((command,args)=>{callLog.textContent+=`${command} ${JSON.stringify(args)}\n`;
   if(command==='auth_action'&&args?.action==='status')return {state:'signed_out',hasEnrollment:false,principal:null,providerLogout:null};
   if(command==='hide_main')return;
   throw new Error('Unexpected fixture command');
  });
  await import('../../src/app/main');
 });
}
if(new URLSearchParams(location.search).has('presence')){
  Promise.all([import('react'),import('react-dom/client'),import(/* @vite-ignore */ source+'Companion.tsx')]).then(([React,{createRoot},{Companion}])=>{
    function Fixture(){
      const [mounted,setMounted]=React.useState(true);const [expression,setExpression]=React.useState('idle');
      const [message,setMessage]=React.useState<any>(null);const [width,setWidth]=React.useState(400);
      return <><button onClick={()=>setMounted(v=>!v)}>Mount toggle</button><button onClick={()=>setExpression(v=>v==='idle'?'blocked':'idle')}>Change expression</button>
        <button onClick={()=>setMessage({id:String(performance.now()),text:'Owner message'})}>New message</button>
        <button onClick={()=>setMessage({id:'unsafe',text:'<img onerror=alert(1)> Hey! جاهز لمساعدتك '+ 'A'.repeat(150)})}>Mixed text</button>
        <button onClick={()=>setWidth(v=>v===0?300:0)}>Zero size</button>
        <div style={{width,maxWidth:'100%'}}>{mounted&&<Companion presentation={{expression,statusText:expression,message}}/>}</div></>;
    }
    createRoot(document.getElementById('root')!).render(<React.StrictMode><Fixture/></React.StrictMode>);
  }).catch(error=>{document.getElementById('root')!.textContent=String(error);});
}
if(new URLSearchParams(location.search).has('studio')){
 Promise.all([import('react-dom/client'),import(/* @vite-ignore */ source+'studio/CompanionStudio.tsx'),import(/* @vite-ignore */ source+'Companion.tsx')]).then(([{createRoot},{CompanionStudio},{Companion}])=>{
  function Fixture(){const [open,setOpen]=React.useState(true);return <><Companion/><button onClick={()=>setOpen(v=>!v)}>Studio toggle</button>{open&&<CompanionStudio/>}</>;}
  createRoot(document.getElementById('root')!).render(<React.StrictMode><Fixture/></React.StrictMode>);
 }).catch(error=>{document.getElementById('root')!.textContent=String(error);});
}

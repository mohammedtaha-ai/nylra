import type {MotionInput,Particle,SceneFrame,Viewport} from '../types.ts';
import {DIRECTIONS} from '../catalog.ts';import {fitCharacter} from './geometry.ts';
export type MotionModel={time:number;accumulator:number;x:number;y:number;vx:number;vy:number;lookX:number;lookY:number;tilt:number;angle:number;angularVelocity:number;blink:number;blinkWait:number;blinkClosing:boolean;poke:number;random:()=>number;particles:Particle[]};
export function createMotion(viewport:Viewport,random:()=>number=Math.random):MotionModel{
 const {center}=fitCharacter(viewport);
 return {time:0,accumulator:0,x:center.x,y:center.y,vx:0,vy:0,lookX:0,lookY:0,tilt:0,angle:0,angularVelocity:0,blink:0,blinkWait:2.4+random()*3.2,blinkClosing:false,poke:0,random,
 particles:Array.from({length:28},()=>({x:(random()-.5)*280,y:(random()-.5)*240,z:random(),radius:random()*2.2+.8,alpha:random()*.65+.15,speedY:-(random()*.38+.12)*60,phase:random()*Math.PI*2}))};
}
const clamp=(n:number,min:number,max:number)=>Math.max(min,Math.min(max,n));
export function advanceMotion(m:MotionModel,seconds:number,input:MotionInput):void{
 const elapsed=Number.isFinite(seconds)?clamp(seconds,0,.05):0;m.accumulator+=elapsed;
 const dt=1/120;const {center,scale}=fitCharacter(input.viewport);if(!scale)return;
 const pointer=input.pointer;
 let target={...center};
 if(input.scene==='cursor'&&pointer)target={x:clamp(pointer.x,150*scale,input.viewport.width-150*scale),y:clamp(pointer.y-15,150*scale,input.viewport.height-150*scale)};
 if(input.scene==='window'&&input.perch)target={x:input.perch.x+input.perch.width/2,y:input.perch.y-38*scale};
 const direction=DIRECTIONS.find(d=>d.id===input.direction);
 const tx=direction?.lx??(input.settings.followPointer&&pointer?clamp((pointer.x-center.x)/Math.max(1,input.viewport.width*.38),-1,1):0);
 const ty=direction?.ly??(input.settings.followPointer&&pointer?clamp((pointer.y-center.y)/Math.max(1,input.viewport.height*.38),-1,1):0);
 while(m.accumulator+1e-10>=dt){m.accumulator=Math.max(0,m.accumulator-dt);m.time+=dt*input.settings.floatSpeed;
  const prev=m.vx,k=input.scene==='cursor'?75:110,d=input.scene==='cursor'?11:14;
  m.vx+=((target.x-m.x)*k-m.vx*d)*dt;m.vy+=((target.y-m.y)*k-m.vy*d)*dt;m.x+=m.vx*dt;m.y+=m.vy*dt;
  m.x=clamp(m.x,150*scale,input.viewport.width-150*scale);m.y=clamp(m.y,150*scale,input.viewport.height-150*scale);
  m.lookX+=(tx-m.lookX)*dt*10;m.lookY+=(ty-m.lookY)*dt*10;m.tilt+=((direction?.tilt??tx*.16)+clamp(m.vx*.0012,-.35,.35)-m.tilt)*dt*9;
  const impulse=(-(m.vx-prev)/dt*.015-(tx-m.lookX)*14)*input.settings.earringSwing;
  m.angularVelocity+=(-38*Math.sin(m.angle)+impulse-m.angularVelocity*3.5)*dt;m.angle+=m.angularVelocity*dt;
  m.blinkWait-=dt;if(m.blinkWait<=0&&!m.blinkClosing){m.blinkClosing=true;m.blinkWait=2.4+m.random()*3.2;}
  if(m.blinkClosing){m.blink=Math.min(1,m.blink+dt*14);if(m.blink===1)m.blinkClosing=false;}else m.blink=Math.max(0,m.blink-dt*12);
  m.poke=Math.max(0,m.poke-dt*4.5);
  m.particles=m.particles.map(p=>({...p,y:p.y<-140?140:p.y+p.speedY*(.6+p.z*.8)*dt}));
 }
}
export function pokeMotion(m:MotionModel):void{m.poke=1;m.angularVelocity+=(m.random()>.5?1:-1)*9;}
export function readFrame(m:MotionModel,input:MotionInput):SceneFrame {
 const {center,scale}=fitCharacter(input.viewport);
 return {character:{cx:scale?clamp(m.x,150*scale,input.viewport.width-150*scale):center.x,cy:scale?clamp(m.y,150*scale,input.viewport.height-150*scale):center.y,scale:scale*(1+Math.sin(m.poke*Math.PI)*.14),lookX:m.lookX,lookY:m.lookY,tilt:m.tilt,time:m.time,earringAngle:m.angle+Math.sin(m.time*3.1)*.08*input.settings.earringSwing,blinkProgress:m.blink,expression:input.presentation.expression,outfit:input.outfit,mini:false,perchingHands:input.scene==='window',sleepingMarks:[{offset:0,size:12},{offset:.33,size:16},{offset:.66,size:20}],notificationPulse:0},particles:m.particles};
}

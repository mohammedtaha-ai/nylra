import {test} from 'node:test';import assert from 'node:assert/strict';import {seededRandom} from './fakes.ts';
import {createMotion,advanceMotion,pokeMotion,readFrame} from '../../src/features/companion/animation/model.ts';
import {DEFAULT_SETTINGS} from '../../src/features/companion/catalog.ts';import type {MotionInput} from '../../src/features/companion/types.ts';
const input:MotionInput={viewport:{width:400,height:360,dpr:1},presentation:{expression:'idle',statusText:'Idle',message:null},settings:DEFAULT_SETTINGS,outfit:'default',scene:'studio',pointer:{x:300,y:180},direction:null,perch:null};
test('motion cadence is stable at 30 60 and 120 Hz and inputs unchanged',()=>{
 const original=JSON.stringify(input);const frames=[30,60,120].map(hz=>{const model=createMotion(input.viewport,seededRandom());for(let i=0;i<hz;i++)advanceMotion(model,1/hz,input);return readFrame(model,input);});
 for(const frame of frames){assert.ok(Math.abs(frame.character.lookX-frames[0].character.lookX)<0.0001);assert.ok(Math.abs(frame.character.time-1)<0.0001);assert.equal(frame.particles.length,28);}
 assert.equal(JSON.stringify(input),original);
});
test('long gaps clamp and resize or zero geometry remain finite',()=>{
 const model=createMotion(input.viewport,seededRandom());advanceMotion(model,100,input);assert.ok(readFrame(model,input).character.time<=0.05+1e-8);
 pokeMotion(model);advanceMotion(model,0,input);const tiny={...input,viewport:{width:0,height:0,dpr:2}};const frame=readFrame(model,tiny);assert.equal(frame.character.scale,0);assert.ok(Number.isFinite(frame.character.cx));
});

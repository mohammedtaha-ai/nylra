import {invoke} from '@tauri-apps/api/core';
import {listen} from '@tauri-apps/api/event';
import {acceptState,connectState,type CompanionState,type CompanionTransport} from './companion-state.ts';
export type {CompanionState} from './companion-state.ts';
const nativeTransport:CompanionTransport={
  listen:handler=>listen<unknown>('companion-state',event=>handler(event.payload)),
  snapshot:()=>invoke('companion_state'),ready:()=>invoke('companion_ready'),
};
export function connectCompanion(onState:(state:CompanionState)=>void,onError:(reason:string)=>void,ready=false,transport=nativeTransport):()=>void {
  return connectState(transport,onState,onError,ready);
}
export async function setCompanionVisible(visible:boolean):Promise<CompanionState>{return acceptState(null,await invoke('set_companion_visible',{visible}));}
export async function setCompanionPaused(paused:boolean):Promise<CompanionState>{return acceptState(null,await invoke('set_companion_paused',{paused}));}
export function dragCompanion():Promise<void>{return invoke('drag_companion');}
export function openMainFromCompanion():Promise<void>{return invoke('open_main_from_companion');}

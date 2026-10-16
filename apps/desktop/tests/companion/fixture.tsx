// Test-only entry: never imported by the application.
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

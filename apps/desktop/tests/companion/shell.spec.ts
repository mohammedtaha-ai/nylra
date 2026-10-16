import {test,expect} from '@playwright/test';
test('production starts idle without synthetic operations',async({page})=>{
 await page.goto('/tests/companion/fixture.html?shell');await expect(page.getByRole('status',{name:'AYLUL status'})).toHaveText('Idle');await expect(page.getByRole('heading',{name:'Account',exact:true})).toBeVisible();await expect(page.getByTestId('fixture-ipc-calls')).not.toContainText('working');
});
test('companion failure preserves account and hide actions',async({page})=>{
 await page.addInitScript(()=>{HTMLCanvasElement.prototype.getContext=(()=>null) as any;});await page.goto('/tests/companion/fixture.html?shell');await expect(page.getByRole('alert')).toContainText('unavailable');
 await page.getByRole('button',{name:'Check session',exact:true}).click();await page.getByRole('button',{name:'Hide to tray',exact:true}).click();
 await expect(page.getByTestId('fixture-ipc-calls')).toContainText('hide_main');await expect(page.getByRole('heading',{name:'Account',exact:true})).toBeVisible();
});
test('studio changes never change auth',async({page})=>{
 await page.goto('/tests/companion/fixture.html?shell');await expect(page.getByText('Signed out',{exact:true})).toBeVisible();
 await page.getByRole('button',{name:'Open development studio',exact:true}).click();
 const studio=page.getByRole('region',{name:'AYLUL development studio'});await studio.getByRole('button',{name:'Working',exact:true}).click();
 await expect(page.getByText('Signed out',{exact:true})).toBeVisible();await expect(page.getByRole('status',{name:'AYLUL status',exact:true})).toHaveText('Idle');
});

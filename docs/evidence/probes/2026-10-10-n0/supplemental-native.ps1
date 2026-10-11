# NON-PRODUCT: follow-up native alternatives and actual shell/input checks.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$env:N0_LOG=Join-Path $probe 'artifacts/runtime-supplemental.jsonl';$env:N0_CONTROL=Join-Path $probe 'artifacts/control.txt'
$p=Start-Process (Join-Path $probe 'target/debug/nylra-n0-probe.exe') -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 4
$out=[System.Collections.Generic.List[object]]::new()
Send-N0Control 'css';Send-N0Control 'size100';Send-N0Control 'overlap';Send-N0Control 'active';Send-N0Control 'focus-main'
foreach($i in 1..3){Start-Sleep -Milliseconds 1100;$out.Add((Save-N0Window 'N0 Synthetic Companion' (Join-Path $probe "artifacts/motion-$i.png")))}
Send-N0Control 'idle';Send-N0Control 'focus-main';$before=[N0Win]::GetForegroundWindow().ToInt64()
Send-N0Control 'offscreen';Send-N0Control 'recover'
$out.Add([PSCustomObject]@{Scenario='park-restore-focus';Before=$before;After=[N0Win]::GetForegroundWindow().ToInt64()})
Send-N0Control 'focus-main';$before=[N0Win]::GetForegroundWindow().ToInt64();Send-N0Control 'hide'
$companion=Get-N0Rect 'N0 Synthetic Companion';$wasVisible=[N0Win]::ShowWindow([IntPtr]$companion.Handle,4);Start-Sleep -Milliseconds 700
$out.Add([PSCustomObject]@{Scenario='ShowWindow-SW_SHOWNOACTIVATE';Before=$before;After=[N0Win]::GetForegroundWindow().ToInt64();PreviouslyVisible=$wasVisible})
Send-N0Control 'hide';Send-N0Control 'focus-main'
# A fresh page's first keyboard tab is the underlying native main button.
[N0Win]::keybd_event(9,0,0,[UIntPtr]::Zero);[N0Win]::keybd_event(9,0,2,[UIntPtr]::Zero)
[N0Win]::keybd_event(32,0,0,[UIntPtr]::Zero);[N0Win]::keybd_event(32,0,2,[UIntPtr]::Zero);Start-Sleep -Milliseconds 500
$out.Add((Save-N0Window 'N0 Synthetic Main' (Join-Path $probe 'artifacts/keyboard-main.png')))
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$condition=New-Object Windows.Automation.PropertyCondition ([Windows.Automation.AutomationElement]::NameProperty),'NON-PRODUCT N0 probe'
$icon=[Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,$condition)
$openedOverflow=$false
if($null -eq $icon) {
 foreach($name in @('Hidden icon menu','Show hidden icons')) {
  $overflowCondition=New-Object Windows.Automation.PropertyCondition ([Windows.Automation.AutomationElement]::NameProperty),$name
  $overflow=[Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,$overflowCondition)
  if($null -ne $overflow){$r=$overflow.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2));$openedOverflow=$true;Start-Sleep -Milliseconds 500;break}
 }
 $icon=[Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,$condition)
}
if($null -eq $icon){$out.Add([PSCustomObject]@{Scenario='tray-shell-click';Status='blocked';Reason='Probe icon not exposed by shell UI Automation in current notification area; no overflow or unrelated icons changed'})}
else {
 Send-N0Control 'tray-rect'
 $trayRect=(Get-Content $env:N0_LOG|ForEach-Object {$_|ConvertFrom-Json}|Where-Object event -eq 'tray_rect'|Select-Object -Last 1).value
 if($trayRect -match 'x: ([\d.-]+), y: ([\d.-]+).*width: ([\d.-]+), height: ([\d.-]+)') {
  $x=[double]$Matches[1];$y=[double]$Matches[2];$w=[double]$Matches[3];$h=[double]$Matches[4]
  Click-N0 ([int]($x+$w/2)) ([int]($y+$h/2))
  $out.Add([PSCustomObject]@{Scenario='tray-shell-click';Name=$icon.Current.Name;NativeRect=$trayRect;Status='native rectangle input sent; confirm runtime tray_input'})
 } else {$out.Add([PSCustomObject]@{Scenario='tray-shell-click';Status='blocked';NativeRect=$trayRect;Reason='No native icon rectangle; a tooltip match alone is insufficient'})}
}
if($openedOverflow){[N0Win]::keybd_event(27,0,0,[UIntPtr]::Zero);[N0Win]::keybd_event(27,0,2,[UIntPtr]::Zero)}
$out|ConvertTo-Json -Depth 7|Set-Content (Join-Path $probe 'artifacts/supplemental-observations.json')
Send-N0Control 'exit'

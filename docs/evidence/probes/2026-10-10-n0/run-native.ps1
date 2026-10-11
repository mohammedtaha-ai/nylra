# NON-PRODUCT. Run from repository root. Leaves reproduction and evidence intact.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$env:N0_LOG=Join-Path $probe 'artifacts/runtime.jsonl';$env:N0_CONTROL=Join-Path $probe 'artifacts/control.txt'
$exe=Join-Path $probe 'target/debug/nylra-n0-probe.exe'
$process=Start-Process -FilePath $exe -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $probe 'artifacts/stdout.log') -RedirectStandardError (Join-Path $probe 'artifacts/stderr.log')
$process.Id | Set-Content (Join-Path $probe 'artifacts/owned-pid.txt')
Start-Sleep -Seconds 4
$observations=[System.Collections.Generic.List[object]]::new()
Send-N0Control 'hide'
Send-N0Control 'board';Start-Sleep -Seconds 2
$observations.Add((Save-N0Window 'N0 AYLUL Asset Inspection' (Join-Path $probe 'artifacts/asset-comparison.png')))
Send-N0Control 'board-close'
Send-N0Control 'board-v2';Start-Sleep -Seconds 2
$observations.Add((Save-N0Window 'N0 AYLUL Asset Inspection' (Join-Path $probe 'artifacts/asset-comparison-v2.png')))
Send-N0Control 'board-close'
Send-N0Control 'show'
Send-N0Control 'overlap';Send-N0Control 'focus-main'
$observations.Add((Save-N0Window 'N0 Synthetic Main' (Join-Path $probe 'artifacts/transparency.png')))
Send-N0Control 'restricted'
Click-N0 205 205;Click-N0 290 290
Send-N0Control 'unrestricted';Send-N0Control 'recover'
$before=Get-N0Rect 'N0 Synthetic Companion'
[N0Win]::SetCursorPos(($before.Left+80),($before.Top+80))|Out-Null
[N0Win]::mouse_event(2,0,0,0,[UIntPtr]::Zero)
Set-Content $env:N0_CONTROL 'drag' -NoNewline;Start-Sleep -Milliseconds 350
[N0Win]::SetCursorPos(($before.Left+140),($before.Top+110))|Out-Null;Start-Sleep -Milliseconds 350
[N0Win]::mouse_event(4,0,0,0,[UIntPtr]::Zero);Start-Sleep -Milliseconds 500
$observations.Add([PSCustomObject]@{Scenario='drag';Before=$before;After=(Get-N0Rect 'N0 Synthetic Companion')})
Send-N0Control 'recover'
Send-N0Control 'focus-main';$focusBefore=[N0Win]::GetForegroundWindow().ToInt64()
Send-N0Control 'hide';Send-N0Control 'show';$focusAfter=[N0Win]::GetForegroundWindow().ToInt64()
$observations.Add([PSCustomObject]@{Scenario='hide-show-focus';Before=$focusBefore;After=$focusAfter})
Send-N0Control 'nonfocusable';Send-N0Control 'focus-main';$focusBefore=[N0Win]::GetForegroundWindow().ToInt64()
Send-N0Control 'hide';Send-N0Control 'show';$focusAfter=[N0Win]::GetForegroundWindow().ToInt64()
$observations.Add([PSCustomObject]@{Scenario='nonfocusable-hide-show';Before=$focusBefore;After=$focusAfter})
Send-N0Control 'focusable'
Send-N0Control 'overlap';Send-N0Control 'focus-main'
foreach($s in @('size100','size150','size200')) {Send-N0Control $s;$observations.Add((Save-N0Window 'N0 Synthetic Companion' (Join-Path $probe "artifacts/$s.png")))}
Send-N0Control 'size100';Send-N0Control 'offscreen';$observations.Add((Get-N0Rect 'N0 Synthetic Companion'));Send-N0Control 'recover';$observations.Add((Get-N0Rect 'N0 Synthetic Companion'))
$second=Start-Process -FilePath $exe -PassThru -WindowStyle Hidden;$second.WaitForExit(5000)|Out-Null
$observations.Add([PSCustomObject]@{Scenario='second-instance';SecondPID=$second.Id;Exited=$second.HasExited})
Send-N0Control 'focus-companion'
foreach($k in @(0x11,0x12,0x10,0x7B)){[N0Win]::keybd_event($k,0,0,[UIntPtr]::Zero)}
Start-Sleep -Milliseconds 100
foreach($k in @(0x7B,0x10,0x12,0x11)){[N0Win]::keybd_event($k,0,2,[UIntPtr]::Zero)}
Start-Sleep -Milliseconds 700
$observations.Add([PSCustomObject]@{Scenario='shortcut-focus';Foreground=[N0Win]::GetForegroundWindow().ToInt64();Main=(Get-N0Rect 'N0 Synthetic Main').Handle})
Send-N0Control 'tray-hide';Send-N0Control 'tray-show'
$observations | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $probe 'artifacts/native-observations.json')
[Windows.Forms.Screen]::AllScreens | Select-Object DeviceName,Primary,Bounds,WorkingArea | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $probe 'artifacts/displays.json')
Write-Output "Native scenarios recorded; owned process $($process.Id) remains for measurement."

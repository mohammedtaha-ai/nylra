# NON-PRODUCT follow-up: paired visibility/focus and actual tray menu delivery.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$outDir=Join-Path $probe 'artifacts/2026-10-11'
$env:N0_LOG=Join-Path $outDir 'runtime-native.jsonl';$env:N0_CONTROL=Join-Path $outDir 'control.txt'
$p=Start-Process (Join-Path $probe 'target/debug/nylra-n0-probe.exe') -PassThru -WindowStyle Hidden
$results=[Collections.Generic.List[object]]::new()
try {
 Start-Sleep -Seconds 3;Send-N0Control 'normalize';Send-N0Control 'css';Send-N0Control 'active';Send-N0Control 'focus-main'
 Start-Sleep -Seconds 2;Send-N0Control 'hide';Start-Sleep -Seconds 6
 $before=[N0Win]::GetForegroundWindow().ToInt64();Send-N0Control 'show-noactivate';$after=[N0Win]::GetForegroundWindow().ToInt64()
 Send-N0Control 'snapshot';$results.Add([pscustomobject]@{Scenario='native-hide-noactivate-show';Before=$before;After=$after;FocusPreserved=($before -eq $after)})
 Start-Sleep -Seconds 6;Send-N0Control 'idle'
 # Resolve the icon's actual shell rectangle without relying on a tooltip match.
 Add-Type -AssemblyName UIAutomationClient;Add-Type -AssemblyName UIAutomationTypes
 foreach($name in @('Hidden icon menu','Show hidden icons')) {
  $cond=New-Object Windows.Automation.PropertyCondition ([Windows.Automation.AutomationElement]::NameProperty),$name
  $overflow=[Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,$cond)
  if($null -ne $overflow){$r=$overflow.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2));break}
 }
 Send-N0Control 'tray-rect'
 $rect=(Get-Content $env:N0_LOG|ForEach-Object {$_|ConvertFrom-Json}|Where-Object event -eq 'tray_rect'|Select-Object -Last 1).value
 if($rect -match 'x: ([\d.-]+), y: ([\d.-]+).*width: ([\d.-]+), height: ([\d.-]+)') {
  $rx=[int]$Matches[1];$ry=[int]$Matches[2];$rw=[int]$Matches[3];$rh=[int]$Matches[4]
  $bmp=New-Object Drawing.Bitmap $rw,$rh;$g=[Drawing.Graphics]::FromImage($bmp);$g.CopyFromScreen($rx,$ry,0,0,$bmp.Size);$bmp.Save((Join-Path $outDir 'tray-icon-rectangle.png'),[Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$bmp.Dispose()
  Click-N0 ([int]([double]$Matches[1]+[double]$Matches[3]/2)) ([int]([double]$Matches[2]+[double]$Matches[4]/2));Start-Sleep -Seconds 1
  # Windows may return the overflow-arrow rectangle for a hidden icon. Resolve
  # the actual owned Button after opening overflow; never click a tooltip.
  $ownedCondition=New-Object Windows.Automation.PropertyCondition ([Windows.Automation.AutomationElement]::NameProperty),'NON-PRODUCT N0 probe'
  $ownedIcons=[Windows.Automation.AutomationElement]::RootElement.FindAll([Windows.Automation.TreeScope]::Descendants,$ownedCondition)
  foreach($owned in $ownedIcons){if($owned.Current.ControlType -eq [Windows.Automation.ControlType]::Button){$r=$owned.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2));Start-Sleep -Seconds 1;break}}
  # Select only the probe-owned menu item when the actual menu is exposed.
  $cond=New-Object Windows.Automation.PropertyCondition ([Windows.Automation.AutomationElement]::NameProperty),'N0 Show Main'
  $item=[Windows.Automation.AutomationElement]::RootElement.FindFirst([Windows.Automation.TreeScope]::Descendants,$cond)
  if($null -ne $item){$r=$item.Current.BoundingRectangle;Click-N0 ([int]($r.Left+$r.Width/2)) ([int]($r.Top+$r.Height/2));Start-Sleep -Seconds 1}
  $events=@(Get-Content $env:N0_LOG|ForEach-Object {$_|ConvertFrom-Json}|Where-Object {$_.event -eq 'tray_input' -or $_.event -eq 'tray_menu'})
  $results.Add([pscustomobject]@{Scenario='tray-shell-menu';NativeRect=$rect;MenuExposed=($null -ne $item);RecordedEvents=$events.Count;Passed=($events.Count -gt 0)})
 }else{$results.Add([pscustomobject]@{Scenario='tray-shell-menu';Passed=$false;Reason='No native rectangle'})}
 [N0Win]::keybd_event(27,0,0,[UIntPtr]::Zero);[N0Win]::keybd_event(27,0,2,[UIntPtr]::Zero)
 $results|ConvertTo-Json -Depth 6|Set-Content (Join-Path $outDir 'native-observations.json')
} finally {Send-N0Control 'exit';$p.WaitForExit(5000)|Out-Null}

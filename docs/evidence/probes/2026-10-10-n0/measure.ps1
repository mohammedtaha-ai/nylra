# NON-PRODUCT: aggregate owned Tauri + descendant WebView2 processes; no other apps.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
$env:N0_CONTROL=Join-Path $probe 'artifacts/control.txt'
$rootId=[int](Get-Content (Join-Path $probe 'artifacts/owned-pid.txt'))
$rows=[System.Collections.Generic.List[object]]::new()
foreach($stage in @('idle','active','hidden','reshown','reduced')) {
 $cmd=switch($stage){'hidden'{'hide'} 'reshown'{'show'} default{$stage}}
 Set-Content $env:N0_CONTROL $cmd -NoNewline;Start-Sleep -Seconds 2
 $previousCpu=$null;$previousTime=$null
 for($i=0;$i -lt 11;$i++) {
  $all=Get-CimInstance Win32_Process | Select-Object ProcessId,ParentProcessId
  $ids=[System.Collections.Generic.HashSet[int]]::new();$ids.Add($rootId)|Out-Null
  do {$changed=$false;foreach($p in $all){if($ids.Contains([int]$p.ParentProcessId) -and $ids.Add([int]$p.ProcessId)){$changed=$true}}}while($changed)
  $owned=@(foreach($id in $ids){Get-Process -Id $id -ErrorAction SilentlyContinue})
  $cpu=($owned|Measure-Object CPU -Sum).Sum;$now=[DateTime]::UtcNow
  if($null -ne $previousCpu){$seconds=($now-$previousTime).TotalSeconds;$rows.Add([PSCustomObject]@{Stage=$stage;Timestamp=$now.ToString('o');Processes=$owned.Count;CPUOneCorePercent=100*($cpu-$previousCpu)/$seconds;CPUMachinePercent=100*($cpu-$previousCpu)/$seconds/12;WorkingSetMiB=($owned|Measure-Object WorkingSet64 -Sum).Sum/1MB;PrivateMiB=($owned|Measure-Object PrivateMemorySize64 -Sum).Sum/1MB})}
  $previousCpu=$cpu;$previousTime=$now;Start-Sleep -Seconds 2
 }
 $rows|Export-Csv -NoTypeInformation (Join-Path $probe 'artifacts/performance.csv')
 Write-Output "$stage measured"
}
Set-Content $env:N0_CONTROL 'exit' -NoNewline

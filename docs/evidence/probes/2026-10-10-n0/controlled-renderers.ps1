param([string[]]$Renderers=@('canvas','css'),[ValidateSet('debug','release')][string]$Profile='debug',[string]$RunName='2026-10-11',[string]$ShowCommand='show')
# NON-PRODUCT. Matched 128px companion + visible normal 640x480 main.
# Writes new dated artifacts; does not overwrite historical measurements.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$outDir=Join-Path $probe "artifacts/$RunName";New-Item -ItemType Directory -Force $outDir|Out-Null
foreach($renderer in $Renderers) {
 $env:N0_LOG=Join-Path $outDir "runtime-$renderer.jsonl";$env:N0_CONTROL=Join-Path $outDir 'control.txt'
 if(Test-Path $env:N0_LOG){throw 'Use a new RunName; retained evidence must not be overwritten'}
 $p=Start-Process (Join-Path $probe "target/$Profile/nylra-n0-probe.exe") -PassThru -WindowStyle Hidden
 try {
  Start-Sleep -Seconds 3;Send-N0Control 'normalize';Send-N0Control $renderer;Send-N0Control 'focus-main';Start-Sleep -Seconds 6
  $rows=[Collections.Generic.List[object]]::new()
  foreach($stage in @('idle','active','hidden','reshown','reduced')) {
   Send-N0Control 'normalize'
   $cmd=switch($stage){'hidden'{'hide'} 'reshown'{$ShowCommand} default{$stage}}
   Send-N0Control $cmd;Send-N0Control 'snapshot';Start-Sleep -Seconds 2
   $previousCpu=$null;$previousTime=$null
   for($i=0;$i -lt 6;$i++) {
    Send-N0Control 'snapshot'
    $snap=Get-Content $env:N0_LOG|ForEach-Object {$_|ConvertFrom-Json}|Where-Object event -eq 'surface_snapshot'|Select-Object -Last 1
    if($snap.main_minimized -or !$snap.main_visible -or $snap.main_size -ne 'PhysicalSize { width: 640, height: 480 }' -or $snap.companion_size -ne 'PhysicalSize { width: 128, height: 128 }' -or $snap.scale -ne 1){throw "Controlled window condition invalid for $renderer/$stage"}
    $all=Get-CimInstance Win32_Process|Select-Object ProcessId,ParentProcessId
    $ids=[Collections.Generic.HashSet[int]]::new();$ids.Add($p.Id)|Out-Null
    do{$changed=$false;foreach($item in $all){if($ids.Contains([int]$item.ParentProcessId) -and $ids.Add([int]$item.ProcessId)){$changed=$true}}}while($changed)
    $owned=@(foreach($id in $ids){Get-Process -Id $id -ErrorAction SilentlyContinue})
    $cpu=($owned|Measure-Object CPU -Sum).Sum;$now=[DateTime]::UtcNow
    if($null -ne $previousCpu){$seconds=($now-$previousTime).TotalSeconds;$rows.Add([pscustomobject]@{Renderer=$renderer;Stage=$stage;Timestamp=$now.ToString('o');Processes=$owned.Count;CPUOneCorePercent=100*($cpu-$previousCpu)/$seconds;CPUMachinePercent=100*($cpu-$previousCpu)/$seconds/[Environment]::ProcessorCount;WorkingSetMiB=($owned|Measure-Object WorkingSet64 -Sum).Sum/1MB;PrivateMiB=($owned|Measure-Object PrivateMemorySize64 -Sum).Sum/1MB;MainMinimized=$snap.main_minimized;MainSize=$snap.main_size;CompanionSize=$snap.companion_size;Scale=$snap.scale})}
    $previousCpu=$cpu;$previousTime=$now;Start-Sleep -Seconds 2
   }
   $rows|Export-Csv -NoTypeInformation (Join-Path $outDir "performance-$renderer.csv")
   Write-Output "$renderer/$stage measured with matched windows"
  }
 } finally {Send-N0Control 'exit';$p.WaitForExit(5000)|Out-Null}
}

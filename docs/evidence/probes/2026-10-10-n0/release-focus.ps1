param([string]$RunName='2026-10-11-release')
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
. (Join-Path $probe 'windows-support.ps1')
$out=Join-Path $probe "artifacts/$RunName"
New-Item -ItemType Directory -Force $out|Out-Null
$env:N0_LOG=Join-Path $out 'runtime-focus.jsonl';$env:N0_CONTROL=Join-Path $out 'focus-control.txt'
if(Test-Path $env:N0_LOG){throw 'Use fresh paths; preserve earlier evidence'}
$p=Start-Process (Join-Path $probe 'target/release/nylra-n0-probe.exe') -PassThru -WindowStyle Hidden
$results=[Collections.Generic.List[object]]::new()
try {
 Start-Sleep -Seconds 3;Send-N0Control 'normalize';Send-N0Control 'active'
 foreach($cycle in 1..20){
  Send-N0Control 'focus-main';$before=[N0Win]::GetForegroundWindow().ToInt64()
  Send-N0Control 'hide';Send-N0Control 'show-noactivate';$after=[N0Win]::GetForegroundWindow().ToInt64()
  $passed=$before -eq $after -and $before -eq (Get-N0Rect 'N0 Synthetic Main').Handle
  $results.Add([pscustomobject]@{Cycle=$cycle;Before=$before;After=$after;Passed=$passed;Companion=(Get-N0Rect 'N0 Synthetic Companion')})
  if(!$passed){throw "Release paired no-activate focus failed at cycle $cycle"}
 }
}finally{
 $results|ConvertTo-Json -Depth 5|Set-Content (Join-Path $out 'focus-observations.json')
 Send-N0Control 'exit';$p.WaitForExit(5000)|Out-Null
}

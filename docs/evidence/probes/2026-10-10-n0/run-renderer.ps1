param([ValidateSet('canvas','css')][string]$Renderer='css')
# NON-PRODUCT renderer measurement reproduction. Run from repository root.
$ErrorActionPreference='Stop'
$probe=Join-Path (Get-Location) 'docs/evidence/probes/2026-10-10-n0'
$env:N0_LOG=Join-Path $probe "artifacts/runtime-$Renderer.jsonl";$env:N0_CONTROL=Join-Path $probe 'artifacts/control.txt'
$p=Start-Process (Join-Path $probe 'target/debug/nylra-n0-probe.exe') -PassThru -WindowStyle Hidden
$p.Id|Set-Content (Join-Path $probe 'artifacts/owned-pid.txt');Start-Sleep -Seconds 4
Set-Content $env:N0_CONTROL $Renderer -NoNewline;Start-Sleep -Seconds 1
& (Join-Path $probe 'measure.ps1')

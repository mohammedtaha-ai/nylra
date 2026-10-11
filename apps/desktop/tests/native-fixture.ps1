$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$out=Join-Path $root 'docs/evidence/probes/2026-10-10-n0/artifacts/2026-10-11-release'
$exe=Join-Path $root 'docs/evidence/probes/2026-10-10-n0/target/release/examples/native_fixture.exe'
# Every operation is a fresh native process. Fixture material is deliberately fake.
foreach($action in @('save','restart','logout','cleared','browser')) {
 & $exe $action $out
 if($LASTEXITCODE -ne 0){throw "Native fixture $action failed"}
}

# NON-PRODUCT N0 Windows reproduction

Retained for reviewer inspection. This directory is an isolated disposable
experiment, not `apps/desktop`, a product library, or a Shadows connector.
No real account/project state is used. Do not delete the only reproduction.

[Report](../../2026-10-10-aylul-windows-probes.md) owns dated results and limitations.
The delivery spec owns acceptance; successful script execution does not close N0.

## Inspected source map

| Source | One named job |
| --- | --- |
| `native/src/main.rs` | Operate synthetic Tauri surfaces and record native outcomes |
| `native/ui/index.html` | Render and instrument synthetic raster presentation |
| `native/ui/compare.html` | Display aspect-preserving board excerpts and trial states |
| `windows-support.ps1` | Wrap Win32 input/window measurement for owned probe windows |
| `run-native.ps1` | Drive the recorded native scenarios |
| `supplemental-native.ps1` | Exercise isolated focus alternatives, keyboard and tray input |
| `measure.ps1` | Aggregate owned-process CPU and memory across five stages |
| `run-renderer.ps1` | Launch a selected renderer for measurement |
| `inspect-assets.py` | Read PNG alpha/geometry without editing images |
| `summarize.py` | Aggregate retained CSV and runtime measurements |
| `check-evidence.py` | Check evidence syntax, hashes, sample completeness and links |
| `prepare-icon.ps1` | Generate a synthetic native resource icon |

Generated art provenance is in asset-manifest.json and asset-prompts.md.
Research-only Coucou snapshots and complete notices are in provenance/.
The native module's inspected contract is colocated at native/contract.yaml.
Drivers record outcomes; they are not comprehensive assertion-based tests.

## Reproduce from repository root

Use a separate repository copy preserving this relative path for reruns;
some output filenames are overwritten and runtime logs append. Prepare-icon uses
its own script path. Other scripts expect the repository-root working directory
and the recorded probe path. No command uses the Shadows target directory or data.

```powershell
& docs/evidence/probes/2026-10-10-n0/prepare-icon.ps1
cargo build --locked --offline --manifest-path docs/evidence/probes/2026-10-10-n0/native/Cargo.toml --target-dir docs/evidence/probes/2026-10-10-n0/target
& docs/evidence/probes/2026-10-10-n0/run-native.ps1
& docs/evidence/probes/2026-10-10-n0/measure.ps1
& docs/evidence/probes/2026-10-10-n0/run-renderer.ps1 -Renderer css
& docs/evidence/probes/2026-10-10-n0/supplemental-native.ps1
python docs/evidence/probes/2026-10-10-n0/inspect-assets.py
python docs/evidence/probes/2026-10-10-n0/summarize.py
python docs/evidence/probes/2026-10-10-n0/check-evidence.py
```

Offline build requires the locked crates already cached; without them, use the
same command without --offline to fetch the required graph. No global JS packages
or Rive/PixiJS authoring dependencies are needed. Build after the owned executable
has exited; Windows locks a running executable.

The native driver leaves its owned process running for measure.ps1, which requests
exit at the end. Supplemental trials also request exit. To stop only this harness,
write `exit` to its artifacts/control.txt; never stop an unrelated daemon.
The app requires N0_LOG and N0_CONTROL absolute paths (set by the drivers), and
uses identifier `local.nylra.n0.probe.20261010`. Its synthetic WebView2 profile
may persist in the user runtime directory; it was not configured with Shadows data.

Follow-up drivers: controlled-renderers.ps1 records matched-window snapshots and
close-native.ps1 exercises paired no-activate visibility and actual tray targeting.
Their 2026-10-11 outputs stay separate under artifacts/2026-10-11. A failed CSS
partial log is retained as .raw, rather than passed off as valid JSONL evidence.

## Failed-variant reproductions

Artifacts retain initial-ui-index.html and initial-native-main.rs for the
resize-every-frame / document.hidden-only trial; canvas-ui-index.html and
canvas-native-main.rs retain the explicit-visibility canvas trial. Copy the chosen
pair into a separate probe copy's native/ui/index.html and native/src/main.rs,
retain the lockfile/assets, rebuild and run the same drivers. Initial native source
also contains unused focusability controls added after the initial measurement;
the measured hide/show and rendering paths are retained. Later supplemental
controls may be unavailable in old variants; run only the measurement sequence.

The first failed screenshot-helper runtime, dependency build failures, locked
executable failure, native observations and tray-tooltip attempts are preserved.
Target binaries/cache and generated icon are ignored; icon source is reproducible.
All PNG trials, source variants, CSVs and JSONL logs required to review the findings
are retained. Neither atlas is an accepted production asset.

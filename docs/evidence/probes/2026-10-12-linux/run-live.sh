#!/usr/bin/env bash
set -euo pipefail
probe_out=${1:?Pass a fresh writable output directory}
mkdir -p "$probe_out"
probe_ui_mode=--live-chat
if [[ ${2:-} == --provider-fixture ]]; then
  export PROBE_PROVIDER_FIXTURE=1
  export MINIMAX_API_KEY=synthetic-test-key
  probe_ui_mode=--owner-fixture
fi
node /workspace/shadows-backend/probes/j1-linux-2026-10-12/native-live.mjs "$probe_out" >"$probe_out/turn-metadata.log" 2>&1 &
backend_pid=$!
trap 'kill "$backend_pid" 2>/dev/null || true' EXIT
for _ in {1..100}; do
  if [[ -f $probe_out/ready ]]; then break; fi
  if ! kill -0 "$backend_pid" 2>/dev/null; then break; fi
  sleep 0.1
done
if [[ ! -f $probe_out/ready ]]; then
  printf '%s\n' 'Owner/backend startup did not complete'
  exit 1
fi
bash docs/evidence/probes/2026-10-12-linux/run-headless.sh "$probe_out" "$probe_ui_mode"

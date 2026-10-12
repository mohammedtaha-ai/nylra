#!/usr/bin/env bash
set -euo pipefail

probe_out=${1:?Pass a writable output directory}
mkdir -p "$probe_out"
probe_home="$probe_out/home"
export XDG_CONFIG_HOME="$probe_home/.config"
export XDG_DATA_HOME="$probe_home/.local/share"
export XDG_CACHE_HOME="$probe_home/.cache"
export XDG_RUNTIME_DIR="$probe_out/runtime"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 -ac -nolisten tcp >"$probe_out/xvfb.log" 2>&1 &
xvfb_pid=$!
app_pid=
mock_pid=
cleanup() {
  if [[ -n $app_pid ]]; then kill "$app_pid" 2>/dev/null || true; fi
  if [[ -n $mock_pid ]]; then kill "$mock_pid" 2>/dev/null || true; fi
  kill "$xvfb_pid" 2>/dev/null || true
}
trap cleanup EXIT

for _ in {1..20}; do
  if xdpyinfo -display :99 >/dev/null 2>&1; then break; fi
  sleep 0.25
done
xdpyinfo -display :99 >/dev/null
WEBKIT_DISABLE_COMPOSITING_MODE=1 \
  apps/desktop/src-tauri/target/debug/nylra-desktop >"$probe_out/app.log" 2>&1 &
app_pid=$!

window_id=
for _ in {1..40}; do
  window_id=$(xdotool search --onlyvisible --name 'NYLRA' 2>/dev/null | head -1 || true)
  if [[ -n $window_id ]]; then break; fi
  if ! kill -0 "$app_pid" 2>/dev/null; then break; fi
  sleep 0.25
done
if [[ -z $window_id ]]; then
  printf '%s\n' 'No visible NYLRA window appeared'
  exit 1
fi
xdotool getwindowname "$window_id"
sleep 2
if [[ ${2:-} == --mock-chat ]]; then
  python3 docs/evidence/probes/2026-10-12-linux/mock-chat.py >"$probe_out/mock.log" 2>&1 &
  mock_pid=$!
  sleep 1
  xdotool mousemove 88 596 click 1
  sleep 2
  xdotool mousemove 680 500 click --repeat 4 --delay 100 5
  sleep 1
elif [[ ${2:-} == --live-chat || ${2:-} == --owner-fixture ]]; then
  xdotool mousemove 88 596 click 1
  if [[ ${2:-} == --live-chat ]]; then sleep 35; else sleep 3; fi
  xdotool mousemove 680 500 click --repeat 4 --delay 100 5
  sleep 1
fi
xwd -display :99 -root -silent -out "$probe_out/window.xwd"
printf '%s\n' 'Captured native Linux window'

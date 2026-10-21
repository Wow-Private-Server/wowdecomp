#!/usr/bin/env bash
# Run the client under Wine on a virtual X display and record the screen to an mp4.
# Usage: Tools/CloudBuild/record.sh <seconds> <output.mp4> [client args...]
# Env: WOW_EXE (default WowClient64.exe), RECORD_SIZE (default 1280x720), RECORD_DISPLAY (default :99)
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
seconds=$1
out=$(realpath -m "$2")
shift 2

display=${RECORD_DISPLAY:-:99}
size=${RECORD_SIZE:-1280x720}
exe=${WOW_EXE:-WowClient64.exe}

if ! xdpyinfo -display "$display" > /dev/null 2>&1; then
    Xvfb "$display" -screen 0 "${size}x24" -nolisten tcp > /dev/null 2>&1 &
    for _ in $(seq 50); do
        xdpyinfo -display "$display" > /dev/null 2>&1 && break
        sleep 0.1
    done
fi

export DISPLAY=$display
export WINEDEBUG=${WINEDEBUG:--all}

cd "$root/bin/Win"
wine "$exe" "$@" > "${out%.mp4}.wine.log" 2>&1 &
ffmpeg -loglevel error -y -f x11grab -video_size "$size" -framerate 20 -i "$display" -t "$seconds" \
    -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -movflags +faststart "$out"
wineserver -k || true
echo "$out"

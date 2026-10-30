#!/usr/bin/env bash
# Trim a moment out of the ORIGINAL file (frame-accurate re-encode).
# Usage: ./trim.sh INPUT.mp4 START END OUTPUT.mp4
#   START/END as seconds (12.5) or timecode (00:01:02.300)
# Tip: add ~0.3s of handle on each side so the clip doesn't start/stop mid-motion.
set -euo pipefail
[ $# -eq 4 ] || { echo "Usage: $0 INPUT START END OUTPUT"; exit 1; }
ffmpeg -v error -y -ss "$2" -to "$3" -i "$1" \
  -c:v libx264 -preset slow -crf 17 -pix_fmt yuv420p -c:a aac -b:a 192k -ar 48000 \
  -movflags +faststart "$4"
echo "Wrote $4"; ffprobe -v error -show_entries format=duration -of default=nw=1 "$4"

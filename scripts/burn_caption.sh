#!/usr/bin/env bash
# Burn a caption PNG (from make_caption.py) onto a 1080x1920 clip.
# Usage: ./burn_caption.sh INPUT.mp4 CAPTION.png OUTPUT.mp4 [START_SEC] [END_SEC]
#   Without START/END the caption stays on the whole clip.
set -euo pipefail
[ $# -ge 3 ] || { echo "Usage: $0 INPUT CAPTION.png OUTPUT [START] [END]"; exit 1; }
EN=""; [ $# -ge 5 ] && EN=":enable='between(t,$4,$5)'"
ffmpeg -v error -y -i "$1" -i "$2" -filter_complex "[0:v][1:v]overlay=0:0${EN},format=yuv420p[v]" \
  -map "[v]" -map 0:a? -c:v libx264 -preset slow -crf 17 -c:a copy -movflags +faststart "$3"
echo "Wrote $3"

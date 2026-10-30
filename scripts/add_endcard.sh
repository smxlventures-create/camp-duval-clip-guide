#!/usr/bin/env bash
# Append a still end card to the end of a 1080x1920 30fps clip, with silent audio under the card.
# Usage: ./add_endcard.sh INPUT.mp4 ENDCARD.png OUTPUT.mp4 [CARD_SECONDS=3]
# Run vertical.sh first so the clip is 1080x1920 @ 30fps (same as the card).
set -euo pipefail
[ $# -ge 3 ] || { echo "Usage: $0 INPUT ENDCARD.png OUTPUT [SECONDS]"; exit 1; }
S=${4:-3}
ffmpeg -v error -y -i "$1" -loop 1 -t "$S" -framerate 30 -i "$2" -f lavfi -t "$S" -i anullsrc=r=48000:cl=stereo \
  -filter_complex "[0:v]scale=1080:1920,fps=30,setsar=1,format=yuv420p[a];\
[1:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black,fps=30,setsar=1,format=yuv420p[c];\
[0:a]aresample=48000,aformat=channel_layouts=stereo[aa];[a][aa][c][2:a]concat=n=2:v=1:a=1[v][au]" \
  -map "[v]" -map "[au]" -c:v libx264 -preset slow -crf 17 -profile:v high -c:a aac -b:a 192k -movflags +faststart "$3"
echo "Wrote $3"

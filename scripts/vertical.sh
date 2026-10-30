#!/usr/bin/env bash
# Make a clip 1080x1920 (9:16) at 30fps.
# Usage: ./vertical.sh INPUT.mp4 OUTPUT.mp4 [crop|pad] [CROP_X]
#   crop (default): fill the frame, cut the sides. CROP_X 0.0=left 0.5=center 1.0=right.
#   pad: fit the whole picture, black bars top/bottom (use for wide shots with key action at edges).
# Also works as the upscale step for 720x1280 phone footage (lanczos scaling).
# Don't upscale more than ~2x the source; it goes soft.
set -euo pipefail
[ $# -ge 2 ] || { echo "Usage: $0 INPUT OUTPUT [crop|pad] [CROP_X]"; exit 1; }
MODE=${3:-crop}; X=${4:-0.5}
if [ "$MODE" = pad ]; then
  VF="scale=1080:1920:force_original_aspect_ratio=decrease:flags=lanczos,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black"
else
  VF="scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos,crop=1080:1920:(iw-1080)*${X}:(ih-1920)/2"
fi
ffmpeg -v error -y -i "$1" -vf "$VF,fps=30,setsar=1,format=yuv420p" \
  -c:v libx264 -preset slow -crf 17 -profile:v high -c:a aac -b:a 192k -ar 48000 \
  -movflags +faststart "$2"
echo "Wrote $2"

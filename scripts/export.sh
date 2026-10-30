#!/usr/bin/env bash
# Final export: loudness to -14 LUFS / -1.5 dBTP, H.264 + AAC, faststart, plus a 4:5 feed version.
# Usage: ./export.sh FINAL_1080x1920.mp4 OUTPUT_BASENAME
#   Writes OUTPUT_BASENAME-1080x1920.mp4 (Reels/TikTok/Shorts) and OUTPUT_BASENAME-1080x1350.mp4 (feed)
set -euo pipefail
[ $# -eq 2 ] || { echo "Usage: $0 INPUT BASENAME"; exit 1; }
AF="loudnorm=I=-14:TP=-1.5:LRA=11"
ffmpeg -v error -y -i "$1" -af "$AF" -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$2-1080x1920.mp4"
ffmpeg -v error -y -i "$1" -vf "crop=1080:1350:0:(ih-1350)/2,setsar=1" -af "$AF" -c:v libx264 -preset slow -crf 18 \
  -pix_fmt yuv420p -r 30 -c:a aac -b:a 192k -ar 48000 -movflags +faststart "$2-1080x1350.mp4"
for f in "$2-1080x1920.mp4" "$2-1080x1350.mp4"; do
  echo "== $f"; ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate:format=duration,size -of compact "$f"
done

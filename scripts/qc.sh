#!/usr/bin/env bash
# Quick QC: specs, loudness, and contact-sheet stills (start/middle/end/last frame).
# Usage: ./qc.sh VIDEO.mp4
set -euo pipefail
V="$1"; B="${V%.*}"
ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate,pix_fmt:format=duration,size -of compact "$V"
ffmpeg -nostats -i "$V" -af ebur128=peak=true -f null - 2>&1 | grep -A12 Summary | grep -E "I:|Peak:" || true
D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V")
for p in 0.05 0.5 0.9; do ffmpeg -v error -y -ss "$(awk -v d="$D" -v p="$p" 'BEGIN{print d*p}')" -i "$V" -frames:v 1 "$B-qc-$p.png"; done
ffmpeg -v error -y -sseof -0.5 -i "$V" -update 1 -frames:v 1 "$B-qc-last.png"
echo "Stills written next to the video. Target: 1080x1920, 30fps, h264+aac, ~-14 LUFS, peak <= -1 dBTP."

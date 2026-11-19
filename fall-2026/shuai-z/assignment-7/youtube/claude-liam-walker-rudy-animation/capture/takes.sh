#!/usr/bin/env bash
# The film's three Movie Maker takes, one after another, on the isolated copy (not the repo). Each window is always on top;
# the driver ends a take (exit 3) the moment its window cannot draw. Then each take is encoded and checked.
set -uo pipefail
S="$(cd "$(dirname "$0")" && pwd)"
cd "$S"
for n in ${TAKES:-1 2 3}; do
  out="$S/take$n"; rm -rf "$out"; mkdir -p "$out"
  echo "== take $n $(date +%T)"
  HOME="$S/home" godot --path game --resolution 3840x2160 --always-on-top --write-movie "$out/play.avi" --fixed-fps 30 -- "take=$n" > "$S/play-0$n-run.log" 2>&1
  code=$?
  echo "godot exit $code $(date +%T)"
  grep -E '^step: THE WINDOW|^draw ' "$S/play-0$n-run.log"
  [ $code -eq 0 ] || { echo "take $n VOID"; continue; }
  python3 frozen.py "$out/play.avi" "play-0$n-run.log" || { echo "take $n VOID (frozen frames)"; continue; }
  python3 compare.py "dry-$n.log" "play-0$n-run.log"
  ffmpeg -v error -y -i "$out/play.avi" -map 0:v -c:v libx264 -preset slow -crf 14 -pix_fmt yuv420p -r 30 "$S/play-0$n.mp4"
  ffmpeg -v error -y -i "$out/play.avi" -map 0:a -c:a pcm_s16le "$S/play-0$n.wav"
  echo "take $n OK $(date +%T)"
done

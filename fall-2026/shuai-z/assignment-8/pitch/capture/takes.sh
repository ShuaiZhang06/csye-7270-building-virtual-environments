#!/usr/bin/env bash
# takes.sh — the Assignment 8 pitch film's three Movie Maker takes of Level 1 at tag a7.
# Adapted by Claude Code from Assignment 7's capture/takes.sh.
#
# CAP is a scratch folder outside the repository holding:
#   game/  — `git archive a7 fall-2026/shuai-z/assignment-7/game`, with the three harness-only changes in
#            game-project.godot.diff and film_driver.gd copied in, imported once with HOME=$CAP/home;
#   home/  — a separate HOME, so the copy never touches the user's Godot settings.
# Each take runs headless first (the dry run), then in a window on top of every other window, since Movie
# Maker needs a renderer and macOS does not draw a covered window. The window's take is kept only if
# check_take.py passes. The MP4 is video only: the game's own audio is not used in the film.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CAP="${CAP:?set CAP to the scratch capture folder}"
mkdir -p "$HERE/logs"
for t in ${TAKES:-run mech pause}; do
  echo "== take $t $(date +%T)"
  HOME="$CAP/home" godot --headless --path "$CAP/game" --fixed-fps 30 -- "take=$t" > "$HERE/logs/take-$t-dry.log" 2>&1
  echo "dry run exit $?"
  out="$CAP/take-$t"; rm -rf "$out"; mkdir -p "$out"
  HOME="$CAP/home" godot --path "$CAP/game" --resolution 3840x2160 --always-on-top --write-movie "$out/play.avi" \
    --fixed-fps 30 -- "take=$t" > "$HERE/logs/take-$t-window.log" 2>&1
  code=$?
  sed -i '' "s#$CAP#\$CAP#g" "$HERE/logs/take-$t-window.log"   # the log names the scratch path; keep it out of the repo
  echo "window exit $code $(date +%T)"
  [ $code -eq 0 ] || { echo "take $t VOID (exit $code)"; continue; }
  python3 "$HERE/check_take.py" "$out/play.avi" "$HERE/logs/take-$t-window.log" "$HERE/logs/take-$t-dry.log" \
    || { echo "take $t VOID"; continue; }
  ffmpeg -v error -y -i "$out/play.avi" -map 0:v -an -c:v libx264 -preset slow -crf 14 -pix_fmt yuv420p -r 30 "$HERE/take-$t.mp4"
  echo "take $t OK $(date +%T)"
done

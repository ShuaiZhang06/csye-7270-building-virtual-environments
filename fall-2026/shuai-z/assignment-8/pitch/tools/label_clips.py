#!/usr/bin/env python3
"""label_clips.py — burns each play clip's label into it and puts the result in the beat's slot, media/<BID>.mp4.

Drafted by Claude Code (Claude Opus 5.5), 2026-11-23. Assignment 8: "Gameplay footage you show is real captured
play from your game, and you say which revision it came from. Scripted-input captures and slowed replays are
labelled as such." The compiler does not draw a beat's `label_on_screen`, so this script does: a cream chip with
ink type (EB Garamond, the film's face) in the bottom-left corner, on every frame of the clip, saying the level,
the tag and "scripted input" (and "2× speed" on the sped-up clip). Type is 96 px on the 3840 × 2160 frame, which is
48 px at the 1920 × 1080 design size, the show-tell skill's floor for body text under GATE T.
The clip is otherwise untouched: same frames, same 30 fps, no audio.
"""
import json
import subprocess
from pathlib import Path

from chip import draw as chip

PITCH = Path(__file__).resolve().parent.parent

sheet = json.loads((PITCH / "beat_sheet.json").read_text())
(PITCH / "media").mkdir(exist_ok=True)
for beat in sheet["beats"]:
    shot = beat["shot"]
    if shot.get("type") != "VIDEO":
        continue
    bid, label = beat["beat_id"], shot["label_on_screen"]
    src = PITCH / shot["evidence_media"]
    png = PITCH / "media" / f".{bid}-label.png"
    chip(label, png)
    out = PITCH / "media" / f"{bid}.mp4"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(src), "-i", str(png), "-filter_complex",
                    "[0:v][1:v]overlay=0:0:format=auto", "-an", "-c:v", "libx264", "-preset", "slow", "-crf", "14",
                    "-pix_fmt", "yuv420p", "-r", "30", str(out)], check=True)
    png.unlink()
    n = subprocess.run(["ffprobe", "-v", "error", "-count_frames", "-select_streams", "v", "-show_entries",
                        "stream=nb_read_frames", "-of", "csv=p=0", str(out)], capture_output=True, text=True).stdout.strip()
    print(f"{bid}: {src.name} + '{label}' -> media/{bid}.mp4 ({n} frames)")

#!/usr/bin/env python3
"""finish_audio.py — after generate_audio_kokoro.py: pads the outro and checks every beat's audio.

Drafted by Claude Code (Claude Opus 5.5), 2026-11-23. The show-tell skill asks for BOUT to end on a 1.0 s silent
tail (its `tail_silence_s`). Kokoro writes the raw length of each beat to mp3/timings.json; this script pads
mp3/beat-BOUT.mp3 to that raw length plus the tail, once (it rebuilds from the raw length, so a second run does
not add a second second), then prints each beat's measured length. make_sheet.py reads those lengths back into
beat_sheet.json, so re-running it keeps them.
"""
import json
import subprocess
import sys
from pathlib import Path

PITCH = Path(__file__).resolve().parent.parent
MP3 = PITCH / "mp3"


def length(path):
    return float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                                 str(path)], capture_output=True, text=True, check=True).stdout)


sheet = json.loads((PITCH / "beat_sheet.json").read_text())
raw = json.loads((MP3 / "timings.json").read_text())
for beat in sheet["beats"]:
    tail = beat.get("tail_silence_s")
    if not tail:
        continue
    bid = beat["beat_id"]
    mp3 = MP3 / f"beat-{bid}.mp3"
    want = round(float(raw[bid]) + float(tail), 2)
    if abs(length(mp3) - want) > 0.06:
        tmp = mp3.with_suffix(".pad.mp3")
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(mp3), "-af",
                        f"atrim=0:{raw[bid]},apad=whole_dur={want}", "-c:a", "libmp3lame", "-q:a", "2", str(tmp)],
                       check=True)
        tmp.replace(mp3)
    print(f"{bid}: padded to {length(mp3):.2f} s (voice {raw[bid]} s + tail {tail} s)")
# Record the text each mp3 was voiced from: every beat after a full run, or only the beats named on the command
# line after a `--only` re-voice. make_sheet.py uses this to refuse audio whose words have changed since.
voiced_path = MP3 / "voiced.json"
voiced = json.loads(voiced_path.read_text()) if voiced_path.exists() else {}
named = set(sys.argv[1:])
for beat in sheet["beats"]:
    if not named or beat["beat_id"] in named:
        voiced[beat["beat_id"]] = beat["narration_text"]
voiced_path.write_text(json.dumps(voiced, indent=1, ensure_ascii=False) + "\n")
total = 0.0
for beat in sheet["beats"]:
    mp3 = MP3 / f"beat-{beat['beat_id']}.mp3"
    if not mp3.exists():
        sys.exit(f"missing {mp3}")
    total += length(mp3)
print(f"{len(sheet['beats'])} beats, {total:.1f} s of narration ({total / 60:.2f} min)")

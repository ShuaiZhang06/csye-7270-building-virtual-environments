#!/usr/bin/env python3
"""cut_clips.py — cuts the film's play clips (clips/C1.mp4 to C5.mp4) from the three Movie Maker takes.

Drafted by Claude Code (Claude Opus 5.5), 2026-11-23. Each VIDEO beat in beat_sheet.json names its take, its frame
range [first, end) in the take's own frame numbers (the "frame N" lines in capture/logs/take-<take>-window.log) and
its speed. The cut is fitted to the beat's measured audio (actual_duration_s): it keeps the window's `anchor` end
and moves the other, so the clip covers the whole narration. The clip is that range of capture/take-<take>.mp4,
re-encoded at 30 fps, video only (the game's audio is not used in the film). A clip at 2x speed keeps every second
frame. The script checks each clip's frame count.
"""
import json
import math
import subprocess
from pathlib import Path

PITCH = Path(__file__).resolve().parent.parent
sheet = json.loads((PITCH / "beat_sheet.json").read_text())
(PITCH / "clips").mkdir(exist_ok=True)
# Each take's frame count, from its window log (check_take.py proved it equals the take's video packets).
TAKE_FRAMES = {t: sum(1 for l in open(PITCH / f"capture/logs/take-{t}-window.log") if l.startswith("frame "))
               for t in ("run", "mech", "pause")}
for beat in sheet["beats"]:
    plan = beat["shot"].get("capture_plan")
    if not plan:
        continue
    speed = plan["speed"]
    need = math.ceil(round(float(beat["actual_duration_s"]) * 30, 3))       # clip frames to cover the beat's audio
    first, end = plan["frames"]
    if plan.get("anchor") == "start":
        end = first + need * speed
    else:
        first = end - need * speed
    take_frames = TAKE_FRAMES[plan["take"]]
    if first < 0 or end > take_frames:
        raise SystemExit(f"{beat['beat_id']}: frames {first}-{end} fall outside take {plan['take']} (0-{take_frames})")
    src = PITCH / plan["take_file"]
    dst = PITCH / beat["shot"]["evidence_media"]
    vf = (f"trim=start_frame={first}:end_frame={end},setpts=PTS-STARTPTS,"
          f"select='not(mod(n\\,{speed}))',setpts=N/(30*TB)")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(src), "-vf", vf, "-an", "-r", "30",
                    "-c:v", "libx264", "-preset", "slow", "-crf", "14", "-pix_fmt", "yuv420p", str(dst)], check=True)
    n = int(subprocess.run(["ffprobe", "-v", "error", "-count_frames", "-select_streams", "v",
                            "-show_entries", "stream=nb_read_frames", "-of", "csv=p=0", str(dst)],
                           capture_output=True, text=True, check=True).stdout.strip())
    want = -(-(end - first) // speed)
    print(f"{beat['beat_id']} {plan['clip']}: take {plan['take']} frames {first}-{end - 1} at {speed}x "
          f"({plan.get('anchor', 'end')} kept) -> {n} frames, {n / 30:.2f} s (audio {beat['actual_duration_s']} s)"
          + ("" if n == want else f"  MISMATCH: expected {want}"))

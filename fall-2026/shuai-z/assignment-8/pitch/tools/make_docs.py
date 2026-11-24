#!/usr/bin/env python3
"""make_docs.py — writes SHOTLIST.md and PROMPTS.md from beat_sheet.json (Gate F needs both before `art run`).

Drafted by Claude Code (Claude Opus 5.5), 2026-11-23. Rerun after make_sheet.py, so the work order always matches
the sheet.
"""
import json
from pathlib import Path

PITCH = Path(__file__).resolve().parent.parent
sheet = json.loads((PITCH / "beat_sheet.json").read_text())
md = sheet["metadata"]


def cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ")


rows = []
for b in sheet["beats"]:
    shot, bid = b["shot"], b["beat_id"]
    dur = b.get("actual_duration_s", b["estimated_duration_s"])
    if shot.get("type") == "VIDEO":
        cp = shot["capture_plan"]
        kind = "play clip"
        picture = f"{cp['clip']}: take `{cp['take']}` at `a7`, {cp['route']}"
        made = "Godot Movie Maker take (CAPTURE.md); cut by tools/cut_clips.py; label by tools/label_clips.py"
        slot = f"media/{bid}.mp4"
        status = shot["label_on_screen"]
    elif shot.get("remotion"):
        kind = "toolkit card"
        picture = f"`{shot['remotion']['pattern']}`"
        made = "Remotion (runtime/scripts/remotion_scenes.py)"
        slot = f"media/{bid}.mp4"
        status = "my name only (checked on rendered stills)"
    elif shot.get("figure"):
        f = shot["figure"]
        kind = "figure"
        picture = f"{f['title']}: `{f['image']}` ({f['image_from']})"
        made = f"Manim `{shot['manim']['class']}` in scenes.py"
        slot = f"manim/{bid}.mp4"
        status = f["status"]
    elif bid == "BOUT":
        kind = "outro"
        picture = "the title, then 'By Shuai Zhang'"
        made = f"Manim `{shot['manim']['class']}` in scenes.py"
        slot = f"manim/{bid}.mp4"
        status = "—"
    else:
        kind = "drawing"
        picture = shot.get("visual_intent", "")
        made = f"Manim `{shot['manim']['class']}` in scenes.py"
        slot = f"manim/{bid}.mp4"
        status = "drawn for this film (show-tell)"
    rows.append(f"| {bid} | {cell(b['act'])} | {kind} | {cell(picture)} | {cell(made)} | `{slot}` | {cell(status)} | {dur:.2f} |")

shotlist = f"""# SHOTLIST — {md['title']}

The work order for every beat, generated from `beat_sheet.json` by `tools/make_docs.py` (drafted by Claude Code,
2026-11-23). One picture per beat, as Assignment 8 asks. Kinds:

- **play clip:** real captured play of Level 1 at tag `a7`, scripted input, labelled on screen.
- **figure:** a figure from GDD.md or a still from a take, framed by a Manim scene, with its status written on screen.
- **drawing:** a show-tell Manim drawing for an idea that has no game picture yet.
- **toolkit card:** the one toolkit opener kept (the hesitant writer).

No `ShowTellCard` is used, so no beat needs a "why a card" reason. Three toolkit components were not used:
- `GodotDesignFigure` prints the instructor's handle with no way to change it, which Assignment 8 forbids. Its figures
  are framed in Manim instead.
- `ClaudeTitleOutro`, for the same reason. The outro is drawn in Manim instead.
- `ClaudeDefinitions` sets its meanings at 40 px on the 2160-line frame, under Gate T's 41 px floor, with no size prop.
  The terms card is drawn in Manim instead (`BDEFS_Terms`).

FRICTIONAL.md has the details: "The pictures" (2026-11-23) and "Rendering the film" (2026-11-23 to 24).

| Beat | Part | Kind | Picture | Made by | Slot | Status on screen | Audio (s) |
| --- | --- | --- | --- | --- | --- | --- | --- |
""" + "\n".join(rows) + "\n"
(PITCH / "SHOTLIST.md").write_text(shotlist)

prompts = f"""# PROMPTS — {md['title']}

**No generation prompts.** Nothing in this film was generated for it.

- **Play:** the clips are real captures of the game at tag `a7` (CAPTURE.md).
- **Drawings:** drawn by code in `scenes.py`.
- **Voice:** Kokoro (am_onyx, a local text-to-speech model) reading the narration in `beat_sheet.json`.

The generated images the film shows (Rudy's frames, the Level 1 cast and screenshots) were made in Assignment 2. Their prompts are logged there (`assignment-2/generated/logs/`, ASSET-LOG.md), and their terms are in Assignment 2's SOURCES.md.

No beat has an open slot waiting for a generated clip: every slot is filled by a capture, a Manim scene or a toolkit card (SHOTLIST.md).
"""
(PITCH / "PROMPTS.md").write_text(prompts)
print(f"SHOTLIST.md: {len(rows)} beats; PROMPTS.md written")

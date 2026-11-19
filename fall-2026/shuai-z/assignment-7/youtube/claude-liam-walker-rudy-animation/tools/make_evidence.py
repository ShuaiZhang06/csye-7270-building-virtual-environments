#!/usr/bin/env python3
"""Write the film's source ledger (schema 1, teaching_contract
code-then-result-v1) for game/, the one Godot project of Assignment 7. Run
after build_reel.py, because the result media are hashed as built.

The course checker takes one folder holding project.godot (--game) and the
reel folder. As in Assignment 5, the ledger goes in a check folder,
checks/game/, holding:
- gamedev-evidence.json;
- beat_sheet.json, a copy of the film's sheet (this film has one project, so
  no beat is left out);
- stills/ and media/, hard links to the reel's result media (not in git), so
  the checker can hash them inside the folder it is given.

    python3 tools/make_evidence.py
    tools/check.sh            # runs the unmodified checker
"""
import hashlib, json, os
from pathlib import Path

REEL = Path(__file__).resolve().parents[1]
A7 = REEL.parents[1]
PROJECT = "game"

COMPONENTS = {
  "run-cycle": ("The looping sprite clip: content/rudy/sheet/rudy_sheet.png, a 4 × 4 sheet of Rudy's 16 Assignment 2 frames (410 × 386 cells, "
                "packed by tools/pack_rudy_sheet.py outside game/), with its .import (mipmaps) and ATTRIBUTION.md; Look/Sprite slices it with "
                "hframes 4 and vframes 4 (content/rudy/rudy.tscn); the run and sword_run clips in animations/rudy_animations.tres key "
                "Sprite:frame on cells 1, 2 and 12, 13 at 0 and 0.125 s, discrete, length 0.25 s, LOOP_LINEAR, step 0.125. "
                "previews/run_preview.gd/.tscn is the fixture the run strips were captured from.",
                lambda p: p.startswith("content/rudy/sheet/") or p == "animations/rudy_animations.tres" or p.startswith("previews/run_preview")
                or p == "content/rudy/rudy.tscn"),
  "slash-rig": ("The committing action on a cutout rig: content/rudy/rig/ holds the body, blade and arc parts cut by tools/cut_slash_rig.py "
                "from CHAR-SWORD-SLASH.png, with their .import files and ATTRIBUTION.md; Look/SlashRig/Lean/Grip/Blade, Lean/Body and Lean/Arc "
                "in content/rudy/rudy.tscn; the slash clip in animations/rudy_animations.tres keys Grip, Lean and Arc at ticks 0, 2, 5, 11 "
                "and 17 of the phase table (17/60 s, LOOP_NONE, step 1/60). previews/slash_preview.gd/.tscn is the fixture the slash strips "
                "were captured from.",
                lambda p: p.startswith("content/rudy/rig/") or p == "animations/rudy_animations.tres" or p.startswith("previews/slash_preview")
                or p == "content/rudy/rudy.tscn"),
  "state-machine": ("The one authority: Look/AnimationPlayer (content/rudy/rudy.tscn, callback_mode_process physics, autoplay empty) is the "
                    "only writer of the Sprite's frame and visibility, SlashRig's visibility and the rig's keyed properties; content/rudy/rudy.gd's "
                    "_pick_clip() is the state machine, a priority list that returns a clip name every physics tick, which _physics_process "
                    "passes to RudyLook.play_clip() (content/rudy/rudy_look.gd), restarting the slash on every new swing; take_hit() ends a "
                    "swing in any phase. project.godot names GL Compatibility and the input actions.",
                    lambda p: p in ("content/rudy/rudy.gd", "content/rudy/rudy_look.gd", "content/rudy/rudy.tscn", "project.godot")),
  "animation-tests": ("The headless tests of this layer: tests/test_rudy_clips.gd/.tscn, the read-back (51 checks: tracks resolve, key times, "
                      "step, loop and update modes, frame range, the structure check, 30 NEGATIVE copies); tests/test_rudy_states.gd/.tscn (99, "
                      "the real Main, every reachable transition); tests/test_rudy_edges.gd/.tscn (108 at 60 fps, 66 at 30: interrupts before, "
                      "on and after each phase boundary); tests/test_rudy_pin.gd/.tscn (20, the behaviour pin, re-pinned).",
                      lambda p: p.startswith("tests/test_rudy_")),
}
BASE_REASON = ("The 2D game as Assignment 6 left it (tag a6, 8cc03ed6), copied unchanged into assignment-7/game; Assignment 7 changed none of "
               "it, and this film covers the layer Assignment 7 added. The earlier tests (checks.gd 141, invulnerable_tint_checks 15, the "
               "four particle tests) guard it and keep their counts.")
REASONS = {"content/rudy/frames/": ("Rudy's 16 Assignment 2 frames and frames.json, unchanged since Assignment 2: the source the sheet is packed "
                                    "from (outside game/, by tools/pack_rudy_sheet.py) and RudyLook.FRAMES. The film shows them packed in the "
                                    "sheet (B04), not file by file.")}


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def inventory(root):
    return sorted(p.relative_to(root).as_posix() for p in root.rglob("*")
                  if p.is_file() and not any(x in (".godot", ".git") for x in p.relative_to(root).parts) and p.suffix != ".uid")


def link(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        dst.unlink()
    os.link(src, dst)


def main():
    sheet = json.loads((REEL / "beat_sheet.json").read_text())
    game = A7 / PROJECT
    out = REEL / "checks" / PROJECT
    beats = sheet["beats"]
    narrated = {b["beat_id"] for b in beats if (b.get("narration_text") or "").strip()}
    files, comp_files, exclusions = [], {c: [] for c in COMPONENTS}, []
    for path in inventory(game):
        ids = [c for c, (_, match) in COMPONENTS.items() if match(path)]
        if not ids:
            reason = next((r for pre, r in REASONS.items() if path.startswith(pre)), BASE_REASON)
            exclusions.append({"path": path, "reason": reason})
            continue
        files.append({"path": path, "sha256": sha(game / path),
                      "role": "import settings" if path.endswith(".import") else path.rsplit(".", 1)[-1], "component_ids": ids})
        for c in ids:
            comp_files[c].append(path)
    comp_beats = {c: [b["beat_id"] for b in beats if b["beat_id"] in narrated and c in b.get("components", [])] for c in COMPONENTS}
    components = [{"id": c, "explanation": e, "beat_ids": comp_beats[c], "files": comp_files[c]} for c, (e, _) in COMPONENTS.items()]
    excerpts, pairs = [], []
    for i, b in enumerate(beats):
        ex = b.get("excerpt")
        if not ex:
            continue
        excerpts.append({"beat_id": b["beat_id"], "path": ex["path"], "start_line": ex["start_line"], "end_line": ex["end_line"],
                         "text": b["shot"]["remotion"]["props"]["code"]})
        r = beats[i + 1]
        media = r["shot"]["evidence_media"]
        link(REEL / media, out / media)
        pairs.append({"code_beat": b["beat_id"], "result_beat": r["beat_id"], "observation": r["shot"]["observation"],
                      "media": {"path": media, "sha256": sha(REEL / media)}})
    meta = sheet["metadata"]
    data = {"schema_version": 1, "teaching_contract": "code-then-result-v1",
            "game": {"name": "walker-rudy assignment-7/game", "revision": meta["game"]["revision"], "folder": "assignment-7/game"},
            "files": files, "components": components, "excerpts": excerpts, "exclusions": exclusions, "code_result_pairs": pairs}
    out.mkdir(parents=True, exist_ok=True)
    (out / "gamedev-evidence.json").write_text(json.dumps(data, indent=1, ensure_ascii=False) + "\n")
    (out / "beat_sheet.json").write_text(json.dumps({"metadata": {**meta, "check_note":
        "Copied by tools/make_evidence.py from ../../beat_sheet.json for the game/ check."}, "beats": beats}, indent=1, ensure_ascii=False) + "\n")
    print(f"{PROJECT}: {len(files)} files, {len(exclusions)} exclusions, {len(components)} components, {len(excerpts)} excerpts, {len(pairs)} pairs")


if __name__ == "__main__":
    main()

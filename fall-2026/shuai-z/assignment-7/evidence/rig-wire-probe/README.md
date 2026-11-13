# Rig-wire probe: the slash rig in the running game, after step 4b

Claude Code wrote and ran this probe on 2026-11-12, while reviewing step 4b. The headless tests cannot see the change in that step. During a swing the pose was `CHAR-SWORD-SLASH` with the one-cell stand-in, and it still is with the rig. So the pin and `checks.tscn` pass the same either way. This probe looks at what is drawn instead.

**How it was run.** As with `evidence/brief-probe/`, the probe ran in a scratch copy of this folder's `game/` (no `.godot/`), never in `game/` itself:
1. `probe_rig_wired.tscn` and `probe_rig_wired.gd` were copied into the copy's `tests/probe/`.
2. The copy was imported once.
3. The probe ran with:

```bash
godot --headless --path game --fixed-fps 60 res://tests/probe/probe_rig_wired.tscn
```

The scene is `test_rudy_pin.tscn` with this script in place of the pin's: a floor, the pickup, the spikes and Rudy. The script hands Rudy the sword by setting `gear` directly. That is something a test would not do, but this is a probe. It presses J once through `Input.parse_input_event`, and logs every tick after Rudy (`process_physics_priority` 100).

**What it showed** (`probe_rig_wired_60fps.log`; tick 0 is the press tick):
- **Ticks 0–16:**
  - the clip is `slash`, at position (tick)/60;
  - the Sprite is hidden, `SlashRig` shows, and the pose is `CHAR-SWORD-SLASH`;
  - Grip follows the keys: −70° on tick 0, −60° on tick 2, 0° on tick 5, +45° on tick 11 and +15.83° on tick 16. These are the values `test_rudy_clips.tscn` samples with `value_track_interpolate()`.
- **The hitbox is live on ticks 2–10.** Its first live tick is the tick of the −60° active key (brief, section 7).
- **Tick 17:** `sword_idle` plays from 0, the Sprite shows again, `SlashRig` hides, and the pose is `CHAR-SWORD-IDLE`.
- **Values left behind.** The rig keeps its last values while hidden: Grip +15.83°, Lean 0.08°, x 0.2. The next swing's keys at 0 set them again.
- **The blade stalls.** It turns 33° on tick 5, then 1.25° on tick 6 and 3.75° on tick 7. That is the stall `sessions/session-7-answer.md` reported, now measured on the real Rudy.

This probe reads numbers only. Headless runs draw nothing, so registration, seams and the look of the motion need a frame strip and my eyes.

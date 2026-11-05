# CLAUDE.md — Assignment 6 (Walker Rudy, 2D)

This folder stands in for the game repository's root. The Godot project is `game/`; run every command from this folder.

## Project context

- **Godot version:** 4.7.2 stable (`v4.7.2.stable.official.ed1daf0bf`, `logs/checks_60fps.log:1`, `logs/import.log:1`). The project declares features `"4.7"` (`game/project.godot:16`).
- **Renderer:** GL Compatibility on desktop and mobile (`game/project.godot:16`, `game/project.godot:95-96`); on this Mac it runs as OpenGL 4.1 on Metal (`evidence/compat-probe/compatibility.log:6`). It does not draw particle trails (`evidence/compat-probe/compatibility.log:4`, `evidence/compat-probe/README.md:34`).
- **Viewport:** 1920 × 1080, `canvas_items` stretch, 1280 × 720 window (`game/project.godot:25-29`).
- **No particles exist yet:** no file in `game/` names a particle class (grep for `Particles`, this session). `game/effects/` and `game/previews/` do not exist yet.

### Effect A — sword-swing sparks (`SlashSparks`)

- **Node type:** a `Node2D` root with two `GPUParticles2D` children, `Flash` and `Sparks`, each with a `ParticleProcessMaterial` (`CHANGE-BRIEF.md:64-66`). Scene to create: `game/effects/slash_sparks.tscn` (`CHANGE-BRIEF.md:66`).
- **Event owner:** `game/content/rudy/rudy.gd`, `_swing()`, which sets `_sword_box.disabled = not live` every physics tick (`rudy.gd:239-242`); `_sword_box` is `$SwordHitbox/Shape` (`rudy.gd:96`, `game/content/rudy/rudy.tscn:34-43`). A swing starts at `rudy.gd:223-226` and is cancelled by a hit (`rudy.gd:143`), a fall (`rudy.gd:168`), a respawn (`rudy.gd:182`) and the circle (`rudy.gd:195`).
- **Signals:** none. Rudy's signals are `respawned`, `hit`, `hearts_changed`, `defeated` (`rudy.gd:35-38`); none marks the hitbox going live, and the brief adds none (`CHANGE-BRIEF.md:41`). The trigger is the true → false edge of `Shape.disabled`, read each physics tick.
- **Place and facing:** the hitbox's global position, `slash_reach` 50 px × `facing`, 76 px above the soles (`rudy.gd:69`, `rudy.gd:240`, `rudy.tscn:41`); `facing` is `rudy.gd:78`.

### Effect B — running dust trail (`RunDust`)

- **Node type:** one `GPUParticles2D` root with a `ParticleProcessMaterial`, `local_coords` off, no `trail_enabled` (`CHANGE-BRIEF.md:158`, `CHANGE-BRIEF.md:171`, `CHANGE-BRIEF.md:190`). Scene to create: `game/effects/run_dust.tscn` (`CHANGE-BRIEF.md:158`).
- **Condition owner:** `game/content/rudy/rudy.gd`: `mode == Mode.PLAY` (`rudy.gd:80`, `rudy.gd:202`), `is_on_floor()` and `absf(velocity.x) > 1.0` (`rudy.gd:306`), the run test in `_pick_pose()` without its swing override (`rudy.gd:295-296`). Velocity is set at `rudy.gd:212-215`; a turn zeroes it (`rudy.gd:204-208`).
- **Signals:** none; the condition is read each physics tick (`CHANGE-BRIEF.md:134`).

### Scenes the effects appear in

- `game/app/main.tscn`: `Main` with `Level1`, `Rudy`, `Camera`, `Hud`, `SystemKeys` (`main.tscn:9-27`). The effects driver and containers go under `Main`, not under Rudy or a goblin (`CHANGE-BRIEF.md:125`, `CHANGE-BRIEF.md:222`). The camera follows Rudy's x (`game/app/main.gd:88`).
- `game/content/level_1/level_1.tscn`: the background they play over; walk line y = 840 (`level_1.tscn:40-44`), goblins (`level_1.tscn:69-77`), sword pickup x = 2500 (`level_1.tscn:79-80`).
- Pause: `Main.toggle_pause()` sets `get_tree().paused` (`main.gd:152-161`); only `SystemKeys` runs while paused (`game/app/system_keys.gd:15`). Reload: `main.gd:207-209`.
- Previews to create: `game/previews/slash_sparks_preview.tscn` and `game/previews/run_dust_preview.tscn` (`CHANGE-BRIEF.md:257`, `CHANGE-BRIEF.md:268`).

### Tests (always through `scripts/run-test.sh`)

Usage: `scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]` (`scripts/run-test.sh:2`, `:21-24`).

```bash
scripts/run-test.sh checks.tscn 60                    # 141 PASS, 0 FAIL (logs/checks_60fps.log)
scripts/run-test.sh invulnerable_tint_checks.tscn 30  # 15 PASS each at 30, 60, 144 (logs/invulnerable_tint_checks_*fps.log)
scripts/run-test.sh invulnerable_tint_checks.tscn 60
scripts/run-test.sh invulnerable_tint_checks.tscn 144
scripts/run-test.sh <test> realtime                   # no --fixed-fps; log is logs/<test>_realtime.log
scripts/run-test.sh <test> 60 300                     # third argument: timeout in s, default 120; 124 = hung
```

- It runs `godot --headless --path game`; `$GODOT`, else `godot` on PATH, else `/Applications/Godot.app/Contents/MacOS/Godot` (`run-test.sh:25`, `:38`).
- A `.tscn` runs as the scene; a `.gd` runs with `--script`, so a `.gd` test must be a script `--script` can run, not one that extends `Node` (`run-test.sh:8-10`, `:31-35`).
- The log is `logs/<test>_<fps>fps.log` or `logs/<test>_realtime.log`; any `SHADER ERROR` or `SCRIPT ERROR` line fails the run even with exit 0 (`run-test.sh:37-41`). The existing logs end with `ERROR: N resources still in use at exit`, which does not fail it (`logs/checks_60fps.log`, last lines).
- `game/tests/capture.tscn` and `capture_tint.tscn` are windowed captures, not headless checks (`game/tests/capture.gd:1-4`, `game/tests/capture_tint.gd:1-7`).
- After every session: `git diff --stat game/shaders/` must print nothing (`CHANGE-BRIEF.md:247`).

## Current change

@CHANGE-BRIEF.md

## Ownership

- Every file in `game/shaders/` is written by hand by the human and is never edited by an agent. That includes `invulnerable_tint.gdshader` and the future `particles_generated.gdshader`, which the human generates in the editor in Step 6 (`CHANGE-BRIEF.md:219`). Do not create, edit, move or delete anything there.
- Effect settings live in the scene files in `game/effects/`, not in code. Driver code only places, mirrors, starts and stops the effects (`CHANGE-BRIEF.md:224`); it never sets a particle or material property.

## Godot 4 names

- Use Godot 4 class and property names for 4.7.2, never Godot 3 names. Not `Particles2D` but `GPUParticles2D`; not `ParticlesMaterial` but `ParticleProcessMaterial`; not `initial_velocity` / `scale` / `damping` / `hue_variation` but their `_min` / `_max` pairs; not `flag_disable_z` / `flag_align_y` but `particle_flag_disable_z` / `particle_flag_align_y`.
- Confirmed in 4.7.2 by the probe that set and ran them (`evidence/compat-probe/probe.gd:23-61`, read back at `compatibility.log:7`): `GPUParticles2D` `amount`, `lifetime`, `texture`, `process_material`, `trail_enabled`; `ParticleProcessMaterial` `particle_flag_disable_z`, `gravity` and `direction` (Vector3), `spread`, `initial_velocity_min/_max`, `emission_shape` (`EMISSION_SHAPE_BOX` = 3), `emission_box_extents` (Vector3), `damping_min/_max`; `GradientTexture2D` `width`, `height`, `fill` (`FILL_RADIAL`), `fill_from`, `fill_to`, `gradient`.
- Every other name the brief uses is not yet exercised in this folder (see Unconfirmed). If you are unsure a property exists in 4.7.2, say so and check it (class reference or a load-and-read-back) instead of guessing. A wrong name in a `.tscn` loads silently at its default, which is predicted failure 1 (`CHANGE-BRIEF.md:283`).

## Out of scope

- No gameplay change: Rudy, goblins, the level, Main's states, the HUD, the audio and the outline material stay as they are (`CHANGE-BRIEF.md:210-216`). Presentation code may read game state but never writes it (`CHANGE-BRIEF.md:225`), and no signal is added to `rudy.gd`.
- No change to collision, movement, input, the state machine or any timing (`CHANGE-BRIEF.md:218`).
- `game/project.godot` stays as it is: the renderer stays GL Compatibility, no input action is added (F9 is read by a new debug node), no setting changes (`CHANGE-BRIEF.md:217`, `:226`).
- No Compatibility-missing feature: no `trail_enabled` trail, no SDF collision, no `emit_particle()` (`CHANGE-BRIEF.md:64`, `:313`). No new child in `rudy.tscn` (`CHANGE-BRIEF.md:194`).
- Existing tests and their expected counts stay the same; new tests go beside them (`CHANGE-BRIEF.md:220`). `main.tscn` gains only presentation nodes (`CHANGE-BRIEF.md:222`).
- Nothing in `game/shaders/` (see Ownership). No image assets: textures are sub-resources in the effect scenes (`CHANGE-BRIEF.md:102`, `:197`).

## Unconfirmed

- Which binary `run-test.sh` will pick: `godot` on PATH is `/opt/homebrew/bin/godot`, but I did not run `--version` on it; 4.7.2 is what the existing logs record.
- These names appear in the brief but in no file here that ran under 4.7.2: `one_shot`, `explosiveness`, `randomness`, `preprocess`, `fixed_fps`, `emitting`, `local_coords`, `visibility_rect`, `use_fixed_seed`, `seed`, `particle_flag_align_y`, `lifetime_randomness`, `scale_min/_max`, `scale_curve`, `color_ramp`, `hue_variation_min/_max`, `CurveTexture`, `GradientTexture1D`. I expect them to exist, but have not confirmed them for this version.
- Whether the brief's `.gd` configuration tests (`CHANGE-BRIEF.md:232`) run as written: through the wrapper they run with `--script`, and no such test exists here yet.
- Whether the editor's Visual Profiler shows GPU time on this Mac; the probe's API read 0.0 ms (`evidence/compat-probe/README.md:36`, failure 12 at `CHANGE-BRIEF.md:294`).
- No existing log is a realtime run, so the realtime mode is known only from `run-test.sh:26-27`.
- `game/tests/invulnerable_tint_checks.gd:4` shows an old usage (`scripts/run-test.sh game ...`) that the current wrapper rejects; `checks.gd:3` calls Godot directly. Use the commands above, and leave those comments alone.
- Rudy's 160 px height comes from `../assignment-2/evidence/1a/1a-run-a.png` (`CHANGE-BRIEF.md:15`), outside this folder; I did not open it.
- The name and place of the effects driver and its containers in `main.tscn` are not set by the brief.

# CLAUDE.md — walker-rudy, Assignment 5

## Project context

This folder holds two Godot projects, `game/` and `godot/`.

**Engine.** Godot 4.7: both `project.godot` files list the feature `"4.7"` (`game/project.godot:16`, `godot/project.godot:16`). The baseline logs print `Godot Engine v4.7.2.stable.official.ed1daf0bf` (`logs/game_checks_60fps.log:1`, `logs/godot_check_props_60fps.log:1`).

**`game/`, the 2D game ("Walker Rudy")**
- Renderer: GL Compatibility, `renderer/rendering_method="gl_compatibility"` on desktop and mobile (`game/project.godot:95-96`).
- Main scene: `res://app/main.tscn` (`game/project.godot:15`).
- Viewport 1920 × 1080, stretch mode `canvas_items` (`game/project.godot:25-29`). No `physics_ticks_per_second` and no HDR 2D setting, so both are at their defaults (`game/project.godot`, whole file).

**`godot/`, the 3D props scene ("Walker Rudy Props 3D")**
- Renderer: Forward+, the feature `"Forward Plus"` with no `rendering_method` override (`godot/project.godot:16`).
- Main scene: `res://scenes/props_room.tscn` (`godot/project.godot:15`).

**The object the 2D effect changes: the hearts**
- `Hud/Hearts` is one `Control` with `hearts.gd`, `texture_filter = 4` and no material (`game/ui/hud.tscn:10-19`).
- `Hearts._draw()` draws all the hearts with `draw_texture_rect()`, using `UI-HEART-FULL.png` for the first `shown` and `UI-HEART-EMPTY.png` for the rest, `SPACING` 60 px apart, at 1/`DENSITY` (`game/ui/hearts.gd:6-9`, `game/ui/hearts.gd:21-24`).
- `hud.gd` sets `max_hearts` and `shown` from Rudy (`game/ui/hud.gd:24-32`). It hides the hearts on the title with `modulate.a = 0.0` (`game/ui/hud.gd:54`) and fades them in with a tween (`game/ui/hud.gd:61`).

**Game state that drives the effect: Rudy's invulnerability, owned by `game/content/rudy/rudy.gd`**
- `invulnerable_time := 1.2` (`rudy.gd:75`); `_invulnerable_left := 0.0` (`rudy.gd:88`).
- `is_invulnerable()` returns `_invulnerable_left > 0.0` (`rudy.gd:112-113`). While it is true, `take_hit()` returns false (`rudy.gd:129-130`).
- The window opens in `take_hit()` (`rudy.gd:144`) and in `respawn_at()` (`rudy.gd:188`).
- `_count_down()` runs it down once per physics tick (`rudy.gd:263-264`); `_physics_process()` calls it (`rudy.gd:230`).
- The existing flicker on `Look` is `modulate.a` (`rudy.gd:232`).
- Tree order in `main.tscn` is Level1, Rudy, Camera, Hud, SystemKeys (`game/app/main.tscn:12-26`).
- The tint colour comes from the waystone: `GLOW := Color(0.6, 0.88, 1.0)` (`game/content/level_1/waystone.gd:19`).

**3D objects for the textured shader** (in `godot/scenes/props_room.tscn`)
- `Waystone` is an instance of `res://assets/props/waystone.glb` (`props_room.tscn:4`, `props_room.tscn:48-49`). Its material `Stone` must stay `#8C8A80` in the imported `.glb` (`godot/tests/check_props.gd:20-21`).
- `TeleportCircle` is an instance of `res://assets/props/teleport_circle.glb` (`props_room.tscn:5`, `props_room.tscn:51-52`). Its material `DarkStone` must stay `#4A4440` (`check_props.gd:22-23`).
- Where their materials come from now: the importer, embedded in each `.glb`. Nothing is extracted (`materials/extract=0` and `_subresources={}` in `godot/assets/props/waystone.glb.import:39-42` and `teleport_circle.glb.import:39-42`), and the scene sets no surface overrides (`props_room.tscn:48-52`).
- `check_props.gd` reads every imported material's `albedo_color` by `resource_name`, but only while the material is a `BaseMaterial3D` (`check_props.gd:81-89`). That is why the brief uses surface material overrides in the scene and not *Use External* (`CHANGE-BRIEF.md` section 5).
- Lighting is the Environment sub-resource and `Sun` (`props_room.tscn:7-13`, `props_room.tscn:40-43`).

**Tests: always run through `scripts/run-test.sh <game|godot> <test-file> <fps>`** (`scripts/run-test.sh:2`)
- Run from this folder: `scripts/run-test.sh game checks.tscn 60` gives 141 checks and ends `all checks passed` (`logs/game_checks_60fps.log`). `checks.tscn` runs `checks.gd` as the scene (`game/tests/checks.tscn`).
- `scripts/run-test.sh godot check_props.gd 60` gives 44 `ok` lines and `PASS: 0 failed check(s)` (`logs/godot_check_props_60fps.log`).
- The wrapper does five things (`scripts/run-test.sh:19-38`):
  - it runs a `.tscn` as the scene and a `.gd` with `--script`;
  - it pins `--fixed-fps`;
  - it times out after 120 s (status 124 means a hang);
  - it writes `logs/<project>_<test>_<fps>fps.log`;
  - it fails on any `SHADER ERROR` or `SCRIPT ERROR` line, whatever the exit code.
- Exit 0 alone is not a pass. Read the log.
- `game/tests/capture.tscn` and `godot/tests/capture_props.gd` open a window and save screenshots (`game/tests/capture.gd:1-7`, `godot/tests/capture_props.gd:1-7`). They are not headless tests.
- Checks that guard this change:
  - Rudy's `Look/Sprite` must keep `res://systems/art/outline.gdshader` (`game/tests/checks.gd:871-877`);
  - only `SpikesA`, `SpikesB` and `GoblinA` may carry a material among the placed level sprites (`game/tests/checks.gd:1056-1061`).

## Current change

@CHANGE-BRIEF.md

## Ownership

Every file in `game/shaders/` and `godot/shaders/` is written by hand by the human. An agent never creates, edits, reformats or "fixes" any of them, even to make a test pass. If a shader looks wrong, report it and stop. Neither folder exists yet.

## Out of scope

- `game/content/rudy/rudy.gd` stays byte for byte. Presentation code may read `_invulnerable_left` and `invulnerable_time`, but never assigns them or any other game state.
- Don't touch movement, collision, input, or the state machine and its timings in `rudy.gd` and `game/app/main.gd`. That covers the 1.2 s window, the 0.35 s hurt time and the 0.12 s flicker.
- Leave the outline material (`systems/art/outline.tres` / `outline.gdshader`) and where it is used alone. Rudy, the goblins, the spikes, the waystone, the circle and the pickup get no new material.
- No HUD element except `Hud/Hearts` changes: not the title, debug line, fade, end card or "Paused".
- No existing test, or anything it expects, changes: 141 checks in `game/`, 44 in `godot/`. New tests are added beside them.
- In `godot/`, the `.glb` files and their `.import` files stay as they are. Don't switch the imported materials to *Use External*, and don't re-run `godot/tools/build_props_room.gd` once the overrides are in.
- Only the waystone's Stone surface and the circle's DarkStone surface get the textured material. Moss, Rune, Gold, PaleGold and the spikes keep their imported colours.
- Leave the lighting and environment of `props_room.tscn` unchanged.
- No project setting changes in either `project.godot`: not the renderer, HDR 2D, physics tick rate or stretch.

## Unconfirmed

- **Surface indices.** I could not confirm that `Stone` is surface 0 of the `Waystone` mesh or that `DarkStone` is surface 1 of the `TeleportCircle` mesh (`CHANGE-BRIEF.md` section 5). Reading the `.glb` JSON needed an approval I did not get. Check with `mesh.surface_get_material(i).resource_name` before writing an override.
- **Node names.** The names of the `MeshInstance3D` nodes inside each instanced `.glb` are unconfirmed.
- **Folders that do not exist yet.** `game/shaders/`, `godot/shaders/`, `godot/materials/`, `godot/assets/textures/` and `godot/assets/hint_experiment/` do not exist. Neither does `game/ui/hearts_tint.tres`, nor `godot/tools/write_grey_strip.gd` (there is a `godot/tools/` folder, but I did not list it).
- **Test counts.** "141" matches the count of `ok`/`PASS` lines in the game log. I did not check the 141 against a count printed by `checks.gd` itself.
- **Brief citations I did not open.** `spikes.gd:18`, `goblin.gd:60`, `main.gd:41-42`, `main.gd:159`, `main.gd:209`, `system_keys.gd` and `music.gd`'s process modes, `rudy.tscn`/`goblin.tscn`/`spikes.tscn` sharing `outline.tres` (only `rudy.tscn:6` was seen), the hint-experiment design and the Poly Haven texture facts.
- **Missing files.** There is no `AGENTS.md` and no `README.md` in this folder.
- **Rendering claims.** These come from the brief, not from files here: the Compatibility renderer uploads canvas uniforms without sRGB conversion, and `hint_range` does not clamp values set from code.

I've done step 3, with one conflict in your spec I couldn't resolve. Everything is written except `logs/import_rig.log`: writing into `logs/` and shell redirection were both refused. Nothing is committed.

The cut passes all its checks: outside the band the composite equals the source pixel for pixel, and no pixel has alpha in both Blade and Body. The real problem is the pommel, which is drawn on top of the sleeve, while the rig draws the sword behind the body (anomaly 1).

## Files
- `tools/cut_slash_rig.py`. Its docstring says Claude Code wrote it, for the commit body.
- `game/content/rudy/rig/slash_blade.png`, `slash_body.png`, `slash_arc.png`, written by the script.
- Their three `.import` files. I wrote `[remap]` plus `[params]` copied line for line from `CHAR-IDLE.png.import`; Godot added the `uid`, `path`, `metadata` and `[deps]` lines. Afterwards each file's `[params]` section still equals `CHAR-IDLE.png.import`'s.
- `evidence/rig-cut/`: `parts_on_grey.png`, `rest_composite_vs_source.png`, `rig_key_times.png` (all written by the script) and `README.md`. The README says these are Python previews without the outline shader.

How the arc was separated: the arc over the robe and shield is not one colour blended at one alpha. Fitting it gives a colour whose blue channel is 263, more than a pixel can hold, so the generated art never treated it as a real layer. So the script repairs each band pixel from the dominant colour of its own material (robe, wood, rim or shield outline, using a shield circle it fits to the visible rim), then solves that pixel's arc colour and alpha so that Arc over Body gives back the source.

## `python3 tools/cut_slash_rig.py`, run 1
```
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 before: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
source: 410 x 386 RGBA; 0 transparent px carry non-zero RGB (the check compares transparent pixels by alpha only)
REGION DATA (pixel (x, y) = column x, row y; a polygon holds a pixel when it holds its centre)
  sword, 1. crossguard: per row y, the sword columns (x from, x to); the 'from' column is the cut along the fist:
      rows 136-152: x 256..284
      rows 153-153: x 263..284
      rows 154-154: x 267..284
      rows 155-155: x 268..284
      rows 156-157: x 269..284
      rows 158-159: x 270..284
      rows 160-165: x 272..284
      rows 166-169: x 273..284
      rows 170-176: x 274..281
  sword, 2. blade: columns 285..349, rows 95..185; in each column from 2 px above the first outline pixel to 1 px below the last one within 26 px of it; outline pixel = luminance < 80 and alpha >= 128
  sword, 3. pommel ellipse: centre (241.0, 177.0), radii (5.6, 6.4)
  sword, 4. grip polygon: [(244.5, 168.5), (249.5, 168.0), (251.5, 173.0), (249.5, 177.5), (245.0, 179.5)]
  sword: every region takes pixels with alpha > 0, except translucent arc-coloured ones
  arc-coloured: RGB within 60 of (234, 241, 251) (Euclidean)
  ARC_ZONE polygon: [(8, 215), (126, 236), (196, 222), (236, 196), (276, 178), (282, 170), (300, 145), (330, 112), (346, 104), (358, 106), (358, 150), (330, 205), (290, 245), (250, 270), (215, 290), (126, 296), (8, 262)]
  ARC_ONLY polygon (no part of him; every non-sword pixel with alpha > 0 is arc): [(276, 100), (362, 100), (362, 205), (300, 242), (252, 264), (240, 238), (241, 200), (277, 181)]
  BAND_POLY polygon (where the arc crosses him): [(124, 238), (160, 233), (190, 229), (198, 224), (215, 224), (232, 208), (250, 206), (254, 240), (246, 272), (215, 284), (180, 286), (150, 288), (124, 286)]
  his edge in BAND_POLY: the shield circle (measured below), and the robe's right edge, the line through (216.0, 248.0) and (228.0, 284.0)
  arc over the background: in ARC_ZONE, not sword, alpha > 0, arc-coloured, not his opaque pixel in BAND_POLY; every pixel with alpha > 0 in BAND_POLY outside his edge; every non-sword pixel in ARC_ONLY; and the translucent arc-coloured pixels in the crossguard rows
  shield circle: fitted to the rightmost opaque, not arc-coloured pixel of rows 186..248 in columns 212..244
  wood radius: rows 196..214, inwards from that edge to the first wood pixel (R - B >= 25 and luminance >= 60), median distance from the centre; shield's left edge: rows 186..200, leftmost wood pixel in x 188..214, median
  repair classes and colour rules: 0 robe: B >= R and luminance >= 70; 1 wood: R - B >= 15 and 45 <= luminance <= 150; 2 rim: |R - B| < 20 and luminance >= 95; 3 outline: luminance < 80
  repair: K 60 nearest known pixels of the class, colour bins of 8, mode; arc alpha clipped to [0, 0.9], 5 x 5 median; repaired when alpha >= 0.03; hue ramp to alpha 0.15; flat-colour ramp 0.55..0.8
  translucent outline pixels in the band with luminance >= 80: colour of the nearest known outline pixel; arc alpha = largest estimate within 2 px (at most the pixel's alpha), Body alpha = (A - a) / (1 - a), arc colour solved
MEASURED REGIONS
  shield circle: centre (195.72, 216.99), radius 40.28 px, from 63 edge pixels, largest residual 2.37 px
  wood radius 32.49 px; shield's left edge x 201
  blade: 61 columns, x 285..345; outline rows at x 285: (141, 155), at x 315: (123, 137), at x 345: (112, 113)
  sword pixels: crossguard 432, blade 915, pommel 110, grip 57 (regions overlap; total below)
  the arc's colour over him: (226.5, 242.5, 263.0), median of 2257 pixels
  band candidates by class: 0 4383, 1 621, 2 386, 3 89
  band: 3102 opaque px repaired (arc alpha estimate median 0.46, max 0.67; stored arc alpha median 0.49), 111 translucent outline px recoloured
  arc over the background: 7669 px
GRIP POINT
  method: the fist is the connected skin-coloured region (R > 200, R - B > 40, opaque) nearest (258, 165), closed twice and hole-filled (282 px); its centroid is (258.18, 162.73)
  the sword's axis: principal axis of the 750 opaque blade pixels, through (311.96, 132.96), direction (0.8582, -0.5134)
  grip point = the centroid projected onto the axis: (259.24, 164.50) texture px; the centroid lies -2.06 px off the axis; the pommel's centre lies +1.37 px off it
  grip relative to the origin (205.0, 370.0): (27.12, -102.75) game px
  drawn angle: -30.89 deg on screen (positive = clockwise), i.e. 30.89 deg above horizontal, pointing right
  reach, grip to tip: 100.55 texture px = 50.28 game px (tip pixel (345, 112), the blade pixel with alpha >= 128 farthest along the axis)
COMPOSITE CHECK (Blade, then Body, then Arc, at rest)
  outside the band: 155047 px, 0 differ from the source
  inside the band: 3213 px, bbox x 124..235, y 208..284; 3122 px exact; mean |difference| R 1.145 G 1.685 B 1.934 A 0.000; largest R 117 G 140 B 161 A 0
  opaque in both Blade and Body: 0 px; alpha > 0 in both: 0 px
previews (Python, no outline shader): evidence/rig-cut/parts_on_grey.png, evidence/rig-cut/rest_composite_vs_source.png, evidence/rig-cut/rig_key_times.png
PARTS SHA-256
  83d1c58ffda6a73118fdd39c7efeda2f491711eba550ba2c570c87c4265fdc63  game/content/rudy/rig/slash_blade.png
  cbbbabd40f96eff39cd5f912ffa80e97aba7a2515b40df5063ae2a653e52653c  game/content/rudy/rig/slash_body.png
  9acc87d15aeec8d7cc4c18fa17c33c50edd797756dc5ee5bf3f9325208c53821  game/content/rudy/rig/slash_arc.png
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
cut: PASS
```

## Run 2
Identical to run 1, line for line. Its last lines:
```
PARTS SHA-256
  83d1c58ffda6a73118fdd39c7efeda2f491711eba550ba2c570c87c4265fdc63  game/content/rudy/rig/slash_blade.png
  cbbbabd40f96eff39cd5f912ffa80e97aba7a2515b40df5063ae2a653e52653c  game/content/rudy/rig/slash_body.png
  9acc87d15aeec8d7cc4c18fa17c33c50edd797756dc5ee5bf3f9325208c53821  game/content/rudy/rig/slash_arc.png
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
cut: PASS
```

## `python3 tools/cut_slash_rig.py --self-test`
```
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 before: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
self-test directory (outside the repository): /var/folders/8s/t65096bj76g2kd8hkybj61f00000gn/T/rudy_rig_selftest_57y8by1w
PASS  undamaged copy (control): the check must pass; it passed
PASS  Blade shifted one pixel right: the check must fail; it failed
        check said: FAIL composite differs from the source outside the band at 1633 px, bbox x 236..346, y 110..183; first at (343, 110): composite (0, 0, 0, 0), source (63, 0, 63, 4)
        check said: FAIL 5 px opaque in both Blade and Body; first at (250, 169)
        check said: FAIL 11 px with alpha > 0 in both Blade and Body; first at (250, 169)
PASS  one sword pixel, (341, 113), left in Body: the check must fail; it failed
        check said: FAIL 1 px opaque in both Blade and Body; first at (341, 113)
        check said: FAIL 1 px with alpha > 0 in both Blade and Body; first at (341, 113)
PASS  the real slash_blade.png was not touched (sha256 83d1c58ffda6a73118fdd39c7efeda2f491711eba550ba2c570c87c4265fdc63)
PASS  the real slash_body.png was not touched (sha256 cbbbabd40f96eff39cd5f912ffa80e97aba7a2515b40df5063ae2a653e52653c)
PASS  the real slash_arc.png was not touched (sha256 9acc87d15aeec8d7cc4c18fa17c33c50edd797756dc5ee5bf3f9325208c53821)
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
self-test: PASS
```
"Left in Body" means the pixel is copied into Body and stays in Blade. If it were moved out of Blade instead, the frame would still composite exactly, and no check could catch it.

## Import and tests
- **`godot --headless --path game --import`** reimported only `slash_arc.png`, `slash_blade.png` and `slash_body.png`. It printed no errors or warnings, only Godot's progress lines ending in `loading_editor_layout ... DONE`.
- **`scripts/run-test.sh test_rudy_clips.tscn 60`:** `RESULT PASS: 28 checks, 0 failed`
- **`scripts/run-test.sh test_rudy_pin.tscn 60`:** `RESULT FAIL: 19 checks, 3 failed, 953 ticks`. That is 16 of 19; the failures are T1, T2 and T6, as committed in step 2b.
- **`scripts/run-test.sh checks.tscn 60`:** 141 PASS lines, and `PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (93 paths; missing: )`, then `all checks passed`. The log's literal last lines are the usual shutdown messages: `WARNING: 34 ObjectDB instances were leaked at exit` and `ERROR: 8 resources still in use at exit`.

## What I see at the seams (a claim; please look too)
- **Blade against the fist.** At −70° and −60° the crossguard sits on top of the knuckles with the blade upright. At +45° it lies against the fist's right side. At ×3, without the shader, I see no gap at the crossguard and no line across the hand.
- **Pommel.**
  - At 5/60 (Grip 0°) it matches the source.
  - At 0 and 2/60, the pommel and grip hang below the fist as a separate stub, and the sleeve's lower-right corner has a notch where the pommel was cut out.
  - At 11/60 the pommel is hidden behind the sleeve, and the notch shows the background.
  - At 17/60 the notch shows too.
- **The band, with the arc hidden.** The broad pale band is mostly gone, but traces remain:
  - an orange-brown streak across the shield's lower wood;
  - a dotted reddish line along the shield's lower rim;
  - faint pale streaks on the robe left of the trim;
  - the chain trim slightly distorted where it crosses the band.

  I expect this to read as the ghost band of predicted failure 12 on the ticks where the arc is hidden (0–1 and 11–16). With the arc shown, the composite at rest equals the source.

## ANOMALIES
1. **The pommel cannot satisfy all of your spec.** It is drawn on top of the sleeve, but the rig draws the Blade behind Body, and the script must assert that no pixel is opaque in both. Repairing the sleeve under the pommel would hide the pommel at rest and fail that assertion. So I kept the assertion and did not repair the sleeve there: Body has a pommel-shaped hole, and the notch shows whenever Grip isn't 0°. Possible fixes are a brief revision (a pommel part drawn after Body, through `z_index` or a separate sprite), or keeping the pommel in Body as the brief's own wording suggests.
2. **`logs/import_rig.log` does not exist.** Writing into `logs/` with the Write tool was refused, and so was the shell redirect `> logs/import_rig.log`. The import output is summarised above. Rerunning the command now finds nothing left to import, so recreating the log needs a fresh reimport.
3. **The arc's alpha and colour are solved per pixel over the robe and the shield.** This follows from the fitted colour's blue channel of 263. Some Arc pixels along the shield's edge came out dark. They can't be seen at rest, but they may show while the arc fades in and out.
4. **91 of the 111 translucent outline pixels in the band are not exact** (largest channel difference 161, B). They are counted inside the band, as the printed numbers show.
5. **A judgement call on a thin light line.** It runs just outside the crossguard's and blade's dark top outline. I gave it to the Arc as part of the arc's trailing line, not to the Blade, because the art keeps every object inside its outline.
6. **How I worked, since Bash ran only the named commands.** I studied the frame through temporary versions of `tools/cut_slash_rig.py`, with zoomed crops written to the scratchpad. Only the final script remains.

**What Godot wrote:** it completed the three new `.import` files and its own `.godot/` cache, which git ignores. Nothing else; no `.uid` file appeared. Of the wrapper's logs, only `logs/checks_60fps.log` changed; the pin and clips logs came out identical.

## git status
```
修改：     logs/checks_60fps.log
未跟踪的文件:
	evidence/rig-cut/
	game/content/rudy/rig/
	sessions/prompt-6.txt
	tools/cut_slash_rig.py
```
(`sessions/prompt-6.txt` was untracked before this session.)

## What still needs you
- Look at the seams in `evidence/rig-cut/rig_key_times.png` and `parts_on_grey.png`, then in the game once step 4 adds the outline shader.
- Decide the pommel (anomaly 1).
- Judge the ghost band. If it shows, brief section 10, row 12 gives the options: repair it again, or keep the arc baked into Body.
- Recreate `logs/import_rig.log` if you want it in the commit.
- Read the script, and decide what to commit, including the changed `checks_60fps.log`.
Both corrections are in, and every check passes. Blade is now only the blade and the crossguard; the pommel and grip stay in Body, unrepaired. Every Arc pixel's colour is now within the arc's own colours. The cost of that rule: 308 band pixels no longer composite exactly at rest, with a largest channel difference of 216 (more below). Nothing is committed.

## What changed, including some departures from "leave the band as it is"
Correction 2 turned up three mistakes of mine, and fixing them touched more than the arc colours:
- **Some dark Arc pixels were his own pixels.** The rule giving pixels "outside his edge" in the band to the Arc had taken parts of his outline and of the shield's lower rim, which lies up to about 1.3 px beyond the fitted circle. The shield now counts as him out to 2.5 px beyond the circle (`SHIELD_MARGIN`). Dark pixels there that are not arc-coloured (luminance below 110, `HIS_EDGE_LUM`) stay in Body.
- **Two blade-tip pixels were in the Arc.** The blade scan missed (342, 112) and (342, 113). A new rule adds a one-pixel dark fringe round the blade, limited to the blade's columns so it can't cross the fist cut.
- **Some Arc pixels over the background were off-colour.** 170 of them are source pixels outside the arc's colours, nearly all faint (alpha median 4, max 197). Following your rule, they are moved into the arc's colours and counted in the band.

Two side effects of the margin needed fixes, and both change band membership a little: 3,103 repaired opaque pixels instead of 3,102, and 140 translucent outline pixels instead of 111.
- My first margin widened the shield-outline repair class to 4 px and drew a dark streak along the shield's bottom. The outline class is back to r − 1.5 to r + 0.5; the margin ring is repaired as robe on the robe's side of the edge line, and as rim elsewhere.
- The rim's light, translucent edge pixels became outline pixels and turned dark. For those pixels the script now searches the split between Body alpha and Arc alpha and takes the closest composite, keeping the most Body on a tie.

The repair method itself is unchanged.

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
  sword, 3. fringe: in columns >= 285, pixels 8-adjacent to 1 and 2, not arc-coloured, luminance < 110
  sword: both regions take pixels with alpha > 0, except translucent arc-coloured ones; the pommel and grip below the fist are not sword: they stay in Body, unrepaired
  arc-coloured: RGB within 60 of (234, 241, 251) (Euclidean)
  ARC_ZONE polygon: [(8, 215), (126, 236), (196, 222), (236, 196), (276, 178), (282, 170), (300, 145), (330, 112), (346, 104), (358, 106), (358, 150), (330, 205), (290, 245), (250, 270), (215, 290), (126, 296), (8, 262)]
  ARC_ONLY polygon (no part of him; every non-sword pixel with alpha > 0 is arc): [(276, 100), (362, 100), (362, 205), (300, 242), (252, 264), (240, 238), (241, 200), (277, 181)]
  BAND_POLY polygon (where the arc crosses him): [(124, 238), (160, 233), (190, 229), (198, 224), (215, 224), (232, 208), (250, 206), (254, 240), (246, 272), (215, 284), (180, 286), (150, 288), (124, 286)]
  his edge in BAND_POLY: the shield circle (measured below), and the robe's right edge, the line through (216.0, 248.0) and (228.0, 284.0); the shield counts out to 2.5 px beyond its circle
  arc over the background: in ARC_ZONE, not sword, alpha > 0, arc-coloured, not his opaque pixel in BAND_POLY; every pixel with alpha > 0 in BAND_POLY outside his edge; every non-sword pixel in ARC_ONLY; and the translucent arc-coloured pixels in the crossguard rows. In BAND_POLY outside his edge, pixels not arc-coloured with luminance < 110 are his outline and stay in Body
  every Arc pixel's colour lies within the arc's colours (the arc-coloured set): arc-over-background pixels outside it are moved into it (radius 59, clipped, rounded) and join the band; over him, for each alpha k/255 the fitting colour is moved into it and the alpha with the closest composite wins (ties: nearest the estimate)
  shield circle: fitted to the rightmost opaque, not arc-coloured pixel of rows 186..248 in columns 212..244
  wood radius: rows 196..214, inwards from that edge to the first wood pixel (R - B >= 25 and luminance >= 60), median distance from the centre; shield's left edge: rows 186..200, leftmost wood pixel in x 188..214, median
  repair classes and colour rules: 0 robe: B >= R and luminance >= 70; 1 wood: R - B >= 15 and 45 <= luminance <= 150; 2 rim: |R - B| < 20 and luminance >= 95; 3 outline: luminance < 80
  repair: K 60 nearest known pixels of the class, colour bins of 8, mode; arc alpha clipped to [0, 0.9], 5 x 5 median; repaired when alpha >= 0.03; hue ramp to alpha 0.15; flat-colour ramp 0.55..0.8
  translucent outline pixels in the band with luminance >= 80: colour of the nearest known outline pixel; the split of the pixel's alpha between Body (b/255) and Arc is searched, the Arc colour moved into the arc's colours, and the closest composite wins (ties: the most Body)
MEASURED REGIONS
  shield circle: centre (195.72, 216.99), radius 40.28 px, from 63 edge pixels, largest residual 2.37 px
  wood radius 32.49 px; shield's left edge x 201
  blade: 61 columns, x 285..345; outline rows at x 285: (141, 155), at x 315: (123, 137), at x 345: (112, 113)
  sword pixels: crossguard 432, blade 915 (regions overlap; total below)
  the arc's colour over him: (226.5, 242.5, 263.0), median of 2258 pixels
  band candidates by class: 0 4383, 1 621, 2 391, 3 89
  band: 3103 opaque px repaired (arc alpha estimate median 0.46, max 0.67; stored arc alpha median 0.49), 140 translucent outline px recoloured
  arc over the background: 7543 px; 170 of them were off the arc's colours and were moved into them (alpha median 4, max 197); they join the band
  so the band is 3103 repaired opaque Body px + 140 recoloured outline px + 170 recoloured Arc px
GRIP POINT
  method: the fist is the connected skin-coloured region (R > 200, R - B > 40, opaque) nearest (258, 165), closed twice and hole-filled (282 px); its centroid is (258.18, 162.73)
  the sword's axis: principal axis of the 750 opaque blade pixels, through (311.96, 132.96), direction (0.8582, -0.5134)
  grip point = the centroid projected onto the axis: (259.24, 164.50) texture px; the centroid lies -2.06 px off the axis
  grip relative to the origin (205.0, 370.0): (27.12, -102.75) game px
  drawn angle: -30.89 deg on screen (positive = clockwise), i.e. 30.89 deg above horizontal, pointing right
  reach, grip to tip: 100.55 texture px = 50.28 game px (tip pixel (345, 112), the blade pixel with alpha >= 128 farthest along the axis)
COMPOSITE CHECK (Blade, then Body, then Arc, at rest)
  outside the band: 154847 px, 0 differ from the source
  inside the band: 3413 px, bbox x 124..345, y 110..284; 3105 px exact; mean |difference| R 3.338 G 2.803 B 2.172 A 0.000; largest R 201 G 207 B 216 A 0
  inside the band, not exact: 308 px, largest channel difference 216
  the largest is at (340, 110): composite RGBA (201, 207, 216, 2), source RGBA (0, 0, 0, 2)
  weighted by alpha (premultiplied RGB, 0..255): largest 37.9 at (140, 238), mean 0.43; 53 band px above 8
  Arc colours: 10786 Arc px with alpha > 0; largest distance from (234, 241, 251): 59.8 (limit: below 60)
  opaque in both Blade and Body: 0 px; alpha > 0 in both: 0 px
previews (Python, no outline shader): evidence/rig-cut/parts_on_grey.png, evidence/rig-cut/rest_composite_vs_source.png, evidence/rig-cut/rig_key_times.png
PARTS SHA-256
  fffb95c5f733d4e0c50f142ef9c90ed4d9a00f6195f68fba2970d79eabd77d55  game/content/rudy/rig/slash_blade.png
  f7056aed1f779493610a790e68248011f59b7f0675026dc15409088aa6d71826  game/content/rudy/rig/slash_body.png
  816b0964b12d953a950012c20d8b9c366ce34b568afe130edfcd4b1e07f939ca  game/content/rudy/rig/slash_arc.png
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
cut: PASS
```
On your counts: 308 band pixels are not exact. The largest channel difference, 216, is at a pixel with alpha 2: a black alpha-2 fringe pixel moved into the arc's colours. Weighted by alpha, the largest difference is 37.9 (out of 255), at (140, 238), and 53 band pixels differ by more than 8.

## Run 2
Identical to run 1, line for line, so the parts' SHA-256 match:
```
PARTS SHA-256
  fffb95c5f733d4e0c50f142ef9c90ed4d9a00f6195f68fba2970d79eabd77d55  game/content/rudy/rig/slash_blade.png
  f7056aed1f779493610a790e68248011f59b7f0675026dc15409088aa6d71826  game/content/rudy/rig/slash_body.png
  816b0964b12d953a950012c20d8b9c366ce34b568afe130edfcd4b1e07f939ca  game/content/rudy/rig/slash_arc.png
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
cut: PASS
```

## `python3 tools/cut_slash_rig.py --self-test`
```
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 before: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
self-test directory (outside the repository): /var/folders/8s/t65096bj76g2kd8hkybj61f00000gn/T/rudy_rig_selftest_03uk2bem
PASS  undamaged copy (control): the check must pass; it passed
PASS  Blade shifted one pixel right: the check must fail; it failed
        check said: FAIL composite differs from the source outside the band at 1514 px, bbox x 256..346, y 110..174; first at (339, 110): composite (0, 0, 0, 0), source (0, 0, 0, 1)
PASS  one sword pixel, (341, 113), left in Body: the check must fail; it failed
        check said: FAIL 1 px opaque in both Blade and Body; first at (341, 113)
        check said: FAIL 1 px with alpha > 0 in both Blade and Body; first at (341, 113)
PASS  the real slash_blade.png was not touched (sha256 fffb95c5f733d4e0c50f142ef9c90ed4d9a00f6195f68fba2970d79eabd77d55)
PASS  the real slash_body.png was not touched (sha256 f7056aed1f779493610a790e68248011f59b7f0675026dc15409088aa6d71826)
PASS  the real slash_arc.png was not touched (sha256 816b0964b12d953a950012c20d8b9c366ce34b568afe130edfcd4b1e07f939ca)
source game/content/rudy/frames/CHAR-SWORD-SLASH.png SHA-256 after: 65f4da7132c98146aa7d250575ec7df18acd70ff5e07c4484e5ba8ffb81fbdfc (matches step 1)
self-test: PASS
```
The shifted Blade now fails on the composite alone. The pommel no longer sits in Blade beside the sleeve, so the shift makes no Blade/Body overlap.

## `godot --headless --path game --import 2>&1 | tee logs/import_rig.log`
Its reimport lines:
```
[   0% ] _update_scan_actions | Started Scanning actions... (3 steps)
[   0% ] _update_scan_actions | slash_arc.png
[  25% ] _update_scan_actions | slash_blade.png
[  50% ] _update_scan_actions | slash_body.png
[   0% ] reimport | Started (Re)Importing Assets (3 steps)
[   0% ] reimport | Executing pre-reimport operations...
[   0% ] reimport | slash_arc.png
[  25% ] reimport | slash_blade.png
[  50% ] reimport | slash_body.png
[  75% ] reimport | Finalizing Asset Import...
[ DONE ] reimport
```
Here I removed the terminal colour codes for reading; `logs/import_rig.log` keeps them, as `tee` wrote them. It shows no warnings or errors. The three `.import` files did not change in this import: they keep the `uid`, `path` and `[deps]` lines Godot added earlier, and `[params]` still equals `CHAR-IDLE.png.import`'s.

## Tests
- **`test_rudy_clips.tscn 60`:** `RESULT PASS: 28 checks, 0 failed`
- **`test_rudy_pin.tscn 60`:** `RESULT FAIL: 19 checks, 3 failed, 953 ticks`. That is 16 of 19; the failures are T1, T2 and T6, as in step 2b.
- **`checks.tscn 60`:** 141 PASS lines. The path check reads `(93 paths; missing: )`, then `all checks passed`. The literal last lines are the usual shutdown messages: `WARNING: 42 ObjectDB instances were leaked at exit` and `ERROR: 8 resources still in use at exit`.

## The fist and pommel at the five key times (my reading; please look too)
The grip and pommel no longer turn, so the sword bends at the fist by the Grip angle. The sleeve is whole at every key, with no notch.
- **0 (Grip −70°):** the blade stands upright above the fist, and the crossguard sits on top of the knuckles. The grip and pommel still point down-left at the drawn angle, so the sword looks kinked by about 70°.
- **2/60 (−60°):** the same, kinked by about 60°.
- **5/60 (0°):** a straight sword, matching the drawing.
- **11/60 (+45°):** the blade points forward and down, and the crossguard lies against the fist's right side. The pommel still trails down-left: a 45° kink.
- **17/60 (+15°):** a 15° kink, which I can barely see at ×3.

At ×3, without the shader, there is no gap and no line where the crossguard meets the fist, at any key. The band on the robe and shield looks as it did before these corrections, with the same traces; per your note, its verdict waits for the frame strip after step 4b.

## git status
```
修改：     logs/checks_60fps.log
未跟踪的文件:
	evidence/rig-cut/
	game/content/rudy/rig/
	logs/import_rig.log
	sessions/prompt-6.txt
	sessions/prompt-6b.txt
	sessions/session-6-answer.md
	tools/cut_slash_rig.py
```
`sessions/prompt-6b.txt` and `sessions/session-6-answer.md` weren't written by me. The wrapper rewrote `test_rudy_clips_60fps.log` and `test_rudy_pin_60fps.log` with the same contents, so git shows no change for them. Godot wrote only its `.godot/` cache, which git ignores.

## Still for a human
- Judge the kinked sword at −70°, −60° and +45° against what you accepted ("the pommel will not turn").
- Judge the band traces on the strip after step 4b.
- Review the extra rules above (`SHIELD_MARGIN`, `HIS_EDGE_LUM`, the blade fringe, the searched alpha split) before committing.
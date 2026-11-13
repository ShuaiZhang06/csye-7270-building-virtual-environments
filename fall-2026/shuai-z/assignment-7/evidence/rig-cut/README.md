# Rig cut: review images (step 3)

`tools/cut_slash_rig.py` writes these three images every time it runs, from the three parts in `game/content/rudy/rig/` and the source frame `game/content/rudy/frames/CHAR-SWORD-SLASH.png`.

**They are previews from Python, not from Godot.** They are drawn without the game's outline shader (`game/systems/art/outline.gdshader`), at texture size (2 texture px per game px), on mid grey (128, 128, 128). In the game, Body and Blade get the 8-texture-px outline and the Arc does not, so seams look different there.

**What the parts hold.**
- Blade: the blade and the crossguard only, from the fist outwards (CHANGE-BRIEF.md, section 2.2).
- Body: everything else of him. That includes the grip and the pommel below and left of the fist, unrepaired, so they do not turn with the blade.
- Arc: the arc alone. Every Arc pixel's colour lies within the arc's own colours, as measured over the background: within 60 of (234, 241, 251). Where that rule stops the composite at rest from equalling the source, the pixel counts in the band. Most such pixels are faint (alpha median 4).

**The images.**
- **`parts_on_grey.png`.** Top row: Blade, Body and Arc side by side, each on its own 410 × 386 canvas, then Body again with the band's edge drawn in yellow. The band is every pixel where the composite at rest may differ from the source:
  - the Body pixels repaired where the arc covered him;
  - his translucent outline pixels in it;
  - the Arc pixels moved into the arc's colours.

  Bottom row: the band area of Body (×3), the same with the band outlined, the source over the same area (×3), and Body's fist with the blade and crossguard removed (×5), with the grip and pommel still in place.
- **`rest_composite_vs_source.png`.** Blade, Body and Arc composited at rest in the rig's draw order (Blade, then Body, then Arc), beside the source. The third panel marks pixels that differ in red and the band in grey: all the red lies inside the band. Bottom row: composite and source at ×3 over the band.
- **`rig_key_times.png`.** The rig at section 2.2's five key times (0, 2/60, 5/60, 11/60 and 17/60 s), with Grip and Lean at those keys and the Arc hidden.
  - Blade turns about the grip point (259.24, 164.50), shown as a magenta cross.
  - Lean turns about his soles at (205, 370), shown as a cyan cross, and moves x game px, at 2 texture px per game px.
  - Positive angles turn clockwise on screen.
  - Row 1: the whole frame. Row 2: the fist, grip and pommel at ×3, centred on the grip. Row 3: the robe and shield at ×2.

The script's printed output gives the region data, the measured grip, angle and reach, and the composite and band numbers. Claude Code (Claude Opus 5.5) wrote the script and this README, and its reading of these images is a claim for the human to check.

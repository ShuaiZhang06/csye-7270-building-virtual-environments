# Character sheet — Rudy

> Draft v2, 2026-10-01, following the assignment's template. This is the contract that generated frames must meet. Images go in `design/character/`. The first committed version uses code-drawn blockouts (see Images below). Generated versions of the reference and poses are added later as a revision below; the blockouts stay in place.

- **Concept in one sentence:** a cheerful chibi boy, 2.5 heads tall, with medium-length, center-parted blond hair that leans toward light brown and one cowlick, green eyes, and a grey mage robe whose large hood lies down on his shoulders; in Level 1 he can pick up a short sword and a small round shield.
- **Game size:** the game renders at 1920×1080 (16:9). In play Rudy is 160 px tall from the soles to the tip of the cowlick (15% of the screen height); his head is about 64 px.
- **Silhouette at on-screen size:** `design/character/silhouette.png` shows the idle, run, sword-idle and block poses filled solid black at 160 px on a 1920×1080 frame. At that size it must read as a big round head, the cowlick, the large hood on his back, a robe that flares at the knees, and, in the sword form, the round shield and the line of the blade.
- **Orientation:** drawn facing right; facing left is a horizontal flip at runtime. The front, three-quarter and back views appear only in the turnaround. Flipping swaps which hand holds the sword and the shield, and that is accepted. When hurt, Rudy turns toward the hit, so the hurt pose is needed in one direction only.
- **Reference:** `design/character/turnaround.png` shows the front, three-quarter, side (facing right) and back views at the same height, with a height bar marked at 160 px and at 2.5 heads.

## Poses

Thirteen poses; at least 10 are required.

| # | Pose | Game state it serves | Plays | Form |
|---|---|---|---|---|
| 1 | Turnaround | reference only (counts as one pose) | — | default |
| 2 | Idle | standing still | loop | default |
| 3 | Run: contact | running | loop | default; the sword form adds the props |
| 4 | Run: passing | running | loop | default; the sword form adds the props |
| 5 | Rising | jump, going up | single | default; the sword form adds the props |
| 6 | Falling | jump, coming down; also the stomp | single | default; the sword form adds the props |
| 7 | Hurt | took a hit; carried gear flies off as a separate sprite | single | default |
| 8 | Defeat | zero hearts | single | default |
| 9 | Respawn | reappearing at a waystone | single | default |
| 10 | Celebrate | on the teleport circle | loop | default |
| 11 | Sword idle | standing with the sword and shield; this pose is the prop callout | loop | sword |
| 12 | Slash | attack | single | sword |
| 13 | Block | holding the shield up, front only; he can walk while blocking | hold | sword |

The staff form's poses (cast, barrier) are added when a later level uses the staff.

## Collision overlay

`design/character/collision.png` shows every pose with the body collision capsule drawn over it at the same scale. The capsule is 64 px wide and 136 px tall, centered on the body, with its bottom on the soles.

Some art extends beyond the capsule:
- the cowlick and the top of the hair, about 24 px;
- the robe flare at the knees, a few px on each side;
- the sword and the shield.

This overhang is fair because it never hurts the player. Enemies, spores and spikes count only when they touch the capsule, so a shot that grazes the hair is a miss. The sword has its own hitbox during the slash, and the shield has its own block zone in front of Rudy. Both are drawn on poses 12 and 13.

## Palette

| Use | Hex |
|---|---|
| Hair, blond leaning toward light brown | `#C2954E` |
| Eyes, green | `#3E8E5E` |
| Robe, slate grey | `#5A606B` |
| Skin | `#F2D6BD` |
| Belt and boots, brown | `#6A4A33` |
| Outline, dark brown | `#3A2A24` |

**Check against the environment.** The table below gives the luminance contrast (WCAG formula) between Rudy's planned colors and the planned Level 1 colors: wheat `#D8B858`, meadow `#8FA85E`, sky `#CFE0E6`, castle `#A3ABB5`, path `#9C8463`.

| Rudy | wheat | meadow | sky | castle | path |
|---|---|---|---|---|---|
| hair | 1.42 | 1.03 | 2.01 | 1.17 | 1.31 |
| robe | 3.29 | 2.39 | 4.66 | 2.73 | 1.78 |
| skin | 1.39 | 1.91 | 1.02 | 1.67 | 2.57 |
| boots | 4.13 | 3.00 | 5.85 | 3.43 | 2.23 |
| outline | 7.10 | 5.16 | 10.06 | 5.89 | 3.84 |

The fills barely separate from the background: the hair is 1.42 against the wheat (1.21 when it was yellow-blond `#E6CC5C`) and 1.03 against the meadow. The robe stays grey, but a slightly darker slate grey: against the wheat it went from 2.38 (`#6F7682`) to 3.29. The outline is what keeps Rudy visible. It is a 4 px dark-brown outer outline, added in-engine around every frame, so it is identical in all of them and does not depend on what the image model draws. `design/character/palette.png` shows the idle blockout on each planned color, in color and in grayscale. These are planned colors. The check is repeated on the generated Rudy over the generated Level 1 background, and if it fails, the background's middle values move, not Rudy's design.

## Consistency rules

Every frame is judged against these rules:

- **Height:** 2.5 heads; the head is 40% of the height; 160 px at game size in every frame.
- **Eyes:** large and green, on the head's horizontal center line, the same shape in every frame.
- **Cowlick:** one, at the crown, always present and always curling the same way.
- **Hair:** medium length, parted in the middle with curtain bangs, covering the ears and ending at the nape; never long and never short. Drawn with visible strands and one highlight band, not as a flat fill.
- **Robe:** slate grey, knee-length, long-sleeved. The large hood is always down, lying on his shoulders and upper back.
- **Accessories:** a brown belt and brown boots; nothing else, no jewelry and no emblems.
- **Outline:** a 4 px dark-brown outer outline at game size, added in-engine and the same in every frame. Interior lines are fine and even.
- **Shading:** two tones (a base and one shadow) under flat, neutral light, plus the hair's highlight band; no rim light, no glow, no cast shadow.
- **Props:** the sword is short and straight; the shield is small, round and wooden, with a plain iron rim and no emblem. Both keep the same size relative to Rudy.
- **Rights:** nothing that recalls a well-known game hero: no green tunic, no pointed cap, no pointed ears, no triangle emblem.

## Images

These are the blockouts for the first committed version. They were drawn by code that Claude wrote, `design/tools/make_blockouts.py`, from the numbers on this sheet; they are not generative-model outputs. I chose this route instead of hand sketches. Regenerate them with `python3 design/tools/make_blockouts.py`.

| File | Shows |
|---|---|
| `design/character/turnaround.png` | front, three-quarter, side and back, with the height bar |
| `design/character/poses.png` | the 13 poses with their labels |
| `design/character/silhouette.png` | the silhouette test at game size |
| `design/character/collision.png` | the capsule, sword hitbox and block zone over every pose |
| `design/character/palette.png` | the palette, and Rudy on each planned Level 1 color |

## Revision 2 — 2026-10-01, after the reference was generated

The sections above are design v1 (tag `design-v1`) and stay as written. Where they differ, this revision wins. The changes come from the accepted reference, `generated/accepted/CHAR-REF-07.jpg`, which Gemini (Nano Banana) generated and I accepted on 2026-10-01 (see ASSET-LOG.md).

- **Reference:** CHAR-REF-07 replaces the blockout turnaround as the reference for every pose. The v1 blockouts still define the poses themselves.
- **Proportions:** about 3.4 heads, measured on CHAR-REF-07's front view: 279 px from the top of the hair to the chin, out of 958 px from the top of the hair to the soles. I chose to keep them for now instead of 2.5 heads.
  - At game size (160 px to the cowlick tip), the chin is at 107 px and the top of the head at 151 px, so the head is about 44 px tall.
  - `design/tools/check_against_sheet.py` draws these two lines.
- **Robe trim:** a thin pale trim, white with a pale-gold line, runs along the hood edge, the front opening, the cuffs and the hem. It is the same in every view, there are no other motifs, and the hem is not split. I added it because a plain robe felt too dull. At 160 px only the trim on the front opening still shows.
- **Body and collision:** the generated body is slimmer than the blockout's. At game size the side view is about 30–34 px wide, and the head about 45 px.
  - A 64 px capsule would make Rudy easier to hit than he looks, so the planned capsule becomes 40 × 136 px.
  - It still has to be re-fitted on the real sprites in the greybox.
- **Palette, sampled from CHAR-REF-07:**

| Use | Hex |
|---|---|
| Hair, light brown | `#C9905A` |
| Eyes, olive green (iris mid-tone) | `#475827` |
| Robe, slate grey | `#6F717D` |
| Skin | `#FCC5A6` |
| Leather: belt and boots | `#754634` |
| Trim, pale gold (with thin white) | `#D4BEA6` |

The drawn lines are a very dark brown, `#290F0D`; the in-engine outer outline uses the same color. Contrast against the planned Level 1 colors:

| Rudy | wheat | meadow | sky | castle | path |
|---|---|---|---|---|---|
| hair | 1.43 | 1.04 | 2.03 | 1.19 | 1.29 |
| eyes | 4.05 | 2.94 | 5.74 | 3.36 | 2.19 |
| robe | 2.52 | 1.83 | 3.57 | 2.09 | 1.36 |
| skin | 1.25 | 1.72 | 1.13 | 1.51 | 2.32 |
| leather | 4.07 | 2.96 | 5.76 | 3.37 | 2.20 |
| trim | 1.07 | 1.48 | 1.32 | 1.29 | 1.99 |
| outline `#290F0D` | 9.34 | 6.79 | 13.23 | 7.75 | 5.04 |

The robe came out lighter than planned: its contrast against the wheat is 2.52, not 3.29. With the outer outline, Rudy stays readable on the wheat and in grayscale; see `generated/checks/CHAR-REF-07-check.png`, whose last row is the silhouette test at game size.

- **Consistency rules:**
  - **Changed:** height and head size follow CHAR-REF-07, and the robe has the trim described above.
  - **Unchanged:** every other v1 rule still holds: one cowlick, the center part, green eyes, the large hood down, brown belt and boots, no jewelry and no emblem.


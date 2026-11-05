# TUNING — Assignment 6, walker-rudy

Each revision follows the assignment's record: what I saw, Claude's reading, the one change I approved, Claude's prediction, the strips before and after, Claude's comparison, and my verdict.

**How this file is written.** "What I saw" and "My verdict" are mine. I said them in Chinese; Claude translated them, and my original words follow in brackets. Claude's readings, predictions and comparisons are Claude's: they are claims about frames, not checks, and where my verdict and Claude's reading disagree, my verdict decides and the disagreement is written here. Every strip is a **fixture capture** of a preview scene (CHANGE-BRIEF.md, section 6), not footage of the game.

---

## 2026-11-04 — Effect A, revision r1

**What I saw** (the preview `game/previews/slash_sparks_preview.tscn`, windowed at the project's 1280 × 720, played three times at real speed, before Claude read any frame): I feel there could be more sparks; right now they are too sparse, too few. [感觉火花可以再多一些，现在太稀疏，太少了]

**Claude's reading of r0** (frames 10, 12, 15, 20, 30 and 50, read after the verdict above; enlarged 3× and 4× around the hitbox to count streaks; sizes in game px, where 1 game px is 2/3 of a frame pixel), against the predictions in CHANGE-BRIEF.md, section 6:

| Frame | The brief predicted | r0 shows | Match |
|---|---|---|---|
| 10 | A white flash about 64 px across with a dark rim, full size; the sparks still inside it | The flash is about 49 px across, with its dark rim, but already see-through: the wheat and the blade show through it. A knot of 6–8 streaks sits inside it, some tinted pale green | Partly: the trigger frame is right; the flash is smaller and fainter than predicted |
| 12 | The flash 1.2× and half faded; 14 white-yellow streaks 15–30 px out, fanned forward and up | No flash is visible. About 9–10 yellow streaks 15–35 px out, bunched into one narrow, nearly horizontal clump | Partly: the distance is right; there is no flash and no visible fan |
| 15 | No flash; yellow streaks 40–70 px out, the lowest bending down | About 11 streaks spread over 20–70 px forward and about 25 px up and down, already orange, 13–19 px long | Partly: the spread is right; the colour is ahead of the prediction |
| 20 | A fresh flash, and around it 6–10 of the first burst's sparks, small and orange, 80–130 px out | The second flash and its knot match frame 10. Of the first burst, only 2 specks about 6 px long are left, low by the grass, 100–140 px forward | No: the overlap is barely visible |
| 30 | The first burst gone; the second burst's small orange sparks falling | 2–3 such specks by the grass, 100–140 px forward | Partly: the same weak tail |
| 50 | Background and Rudy only | Background and Rudy only | Yes |

The dark rims keep every streak readable against the wheat. The density is the weak point, as I saw it in the window: the spray reads as a crowd of sparks only in frames 11 to 15, and by frame 20 almost nothing of the first burst is left, so a fast second cut looks like two separate small puffs.

**Change:** `Sparks` `amount` 14 → 28, proposed by Claude and approved by me. The configuration test's expected value moved with it, and the test passes at 60 fps (`logs/test_slash_sparks_config_60fps.log`). It is the setting that sets how many sparks there are, and it leaves their speed, spread, size, colour and timing alone, so any difference in r1 comes from the count. Two settings were considered and not proposed: a wider `spread` would thin the spray out further, and less `lifetime_randomness` would fill only the late frames. If kept, a burst peaks at 29 particles and two overlapping bursts at 58, not 30 (rule A3 and section 8 of the brief).

**Claude's prediction for r1** (same seeds; the first 14 sparks probably keep their r0 paths, with 14 more added):

| Frame | Predicted |
|---|---|
| 10 | The flash unchanged. The knot inside it about twice as dense: 12–16 streaks overlapping into one solid yellow bundle |
| 12 | Still no flash. 16–20 yellow streaks 15–35 px out: the same clump, about twice as thick, still mostly horizontal |
| 15 | 18–22 orange streaks over the same area, 20–70 px forward, with the gaps between them about halved |
| 20 | The second flash with a doubled knot; 3–5 specks of the first burst by the grass, 100–140 px forward |
| 30 | 3–5 specks by the grass |
| 50 | Background and Rudy only |

What it should not change: the flash, the streaks' size and colour, the reach, and the weak overlap at frame 20, which comes from the sparks' short lives and shrinking, not from their number.

**Claude's comparison of r1 with its prediction** (the same six frames, the same crops, r0 and r1 side by side):

| Frame | Predicted | r1 shows | Match |
|---|---|---|---|
| 10 | The flash unchanged; a knot of 12–16 streaks in one solid bundle | The flash is unchanged. The knot is denser, but the streaks overlap so much that only about 10–12 can be told apart | Yes, though the gain is hard to see on this frame |
| 12 | No flash; 16–20 streaks, the same clump about twice as thick | No flash. About 14–18 streaks in the same place, a visibly thicker clump | Yes |
| 15 | 18–22 orange streaks over 20–70 px, gaps about halved | About 20 orange streaks over the same area; the gaps are clearly smaller | Yes |
| 20 | The second flash with a doubled knot; 3–5 specks of the first burst by the grass | The second flash and knot as predicted. About 8 specks of the first burst, 80–140 px forward, spread from halfway up the frame down to the grass | No: more specks than predicted, and higher |
| 30 | 3–5 specks by the grass | About 7–8 specks, spread the same way | No: more than predicted |
| 50 | Background and Rudy only | Background and Rudy only | Yes |

Where it differs, the likely reason: at frame 20 most sparks are still alive, because `lifetime_randomness` 0.4 gives lives between 0.27 s and 0.45 s, but they are drawn at about a third of their size and partly faded. Whether one still shows as a speck depends on its own random life and size. My prediction doubled r0's two visible specks instead of working out how many lives last past 0.33 s, and the 14 new sparks happen to include several long-lived ones that went higher. So the overlap at frame 20 is easier to see than I predicted, but those sparks are still small and faint.

**My verdict** (the preview, windowed at 1280 × 720, played three times at real speed after Claude's comparison): **kept**. I gave no further reason. The effect was not in the game yet, so this verdict was on the preview. After Step 3 wired it in, I played the game with the 28 sparks and found no problem [我已经进到游戏里看过了，没问题].

**Strips** (fixture captures; Movie Maker, 30 fps, 1280 × 720, seeds 1 and 2, started by Claude at my request; only frames 10, 12, 15, 20, 30 and 50 are kept):
- `captures/slash_sparks/r0/` (`logs/capture_slash_sparks_r0.log`)
- `captures/slash_sparks/r1/` (`logs/capture_slash_sparks_r1.log`)

**Commits:** `ea4419ae` (the effect as the agent built it, unedited); then the commit of strip r0, and the commit that makes this change with strip r1, this entry and the brief's Revision 3.

---

## 2026-11-05 — Effect B, revision r1

**What I saw** (the preview `game/previews/run_dust_preview.tscn`, windowed at the project's 1280 × 720, played six times at real speed, before Claude read any frame): with my own eyes I could not see the dust trail at all. [我肉眼完全没看到尘土拖尾的效果]

**Claude's reading of r0** (frames 10, 13, 25, 40, 46 and 56, read after the verdict above, enlarged 3× behind his feet; sizes in game px). To measure what the eye could not find, Claude also rendered the same preview with `RunDust` hidden, in a scratch copy of the game, and compared each frame pixel by pixel with r0:

| Frame | The brief predicted | r0 shows | Pixels changed by the dust (of 921,600; ≥ 20 of 255 levels; largest change) |
|---|---|---|---|
| 10 | At most one or two faint puffs at his boots | Nothing visible | none found |
| 13 | A line of 3–5 puffs about 55 px long, the oldest fully opaque | Nothing visible enlarged | 596; 8; 26 |
| 25 | A band about 280 px long behind him, darkest at his boots | Only a faint darker smudge in the grass strip, about 230 px long and 45 px tall | 1,973; 136; 52 |
| 40 | The same band as frame 25 | The same faint smudge | 2,168; 224; 49 |
| 46 | The band about 170 px long, paler | Nothing visible | 884; 45; 28 |
| 56 | Nothing | Nothing | — |

The dust is there and roughly the size the brief planned, but it cannot be seen: in the difference image it is about six small separate puffs, and most of the pixels it touches change by less than 20 levels. The brief's contrast figures (2.9:1 against the wheat) assumed opaque dust over the wheat. In the frames the puffs hang in the green grass strip just above the walk line, at no more than 0.75 opacity, with soft edges, so their colour sits close to the grass behind them. Two smaller things: the puffs stay separate instead of overlapping into one band, and at the stop the frozen sword pickup (x 2500) sits right behind Rudy.

**Change:** `RunDust`'s `color_ramp`, one setting, made darker and more opaque, with the same offsets; proposed by Claude and approved by me. The configuration test's expected ramp moved with it, and the test passes 61 of 61 at 60 fps (`logs/test_run_dust_config_60fps.log`):

| Offset | Old | New |
|---|---|---|
| 0 | `#7A6448` α 0 | `#5C4A35` α 0 |
| 0.15 | `#7A6448` α 0.75 | `#5C4A35` α 1.0 |
| 0.6 | `#8A7356` α 0.5 | `#6E5A43` α 0.8 |
| 1 | `#9C8463` α 0 | `#9C8463` α 0 |

At full opacity `#5C4A35` (luminance about 0.07) gives about 3.3:1 against the grass strip and 4.5:1 against the wheat, where the old colour at 0.75 opacity gave about 1.7:1 against the grass at a puff's centre. The size, speed, lifetime and number of puffs stay as they are, so the band keeps the brief's length and height. A bigger `scale` was not proposed: doubling it would make the band about 80 px tall, above his knees, against the brief.

**Claude's prediction for r1** (same seed, so the puffs keep r0's positions and sizes):

| Frame | Predicted |
|---|---|
| 10 | At most one small dark dot at his boots, still fading in |
| 13 | 3–5 small dark-brown puffs behind his boots, clearly darker than the grass, over about 55 px |
| 25 | A dotted dark-brown line about 230 px long and 45 px tall behind him, darkest at his boots and paler at its far end; still separate puffs rather than one band |
| 40 | The same as frame 25 |
| 46 | A shorter, paler line of the oldest puffs, about 90 px long |
| 56 | Nothing |

Measured the same way as r0 at frame 25: at least 500 pixels changed by 20 levels or more (r0: 136), and a largest change of at least 90 levels (r0: 52).

**Claude's comparison of r1 with its prediction** (the same crops side by side, and the same pixel comparison with the no-dust render):

| Frame | Predicted | r1 shows (pixels changed; ≥ 20 levels; largest) | Match |
|---|---|---|---|
| 10 | At most one small dark dot, fading in | Nothing visible (145; 0; 19) | Yes |
| 13 | 3–5 dark-brown puffs behind his boots, clearly darker than the grass, over about 55 px | 2–3 dark-brown smudges in the grass behind his rear boot, over about that span (625; 187; 51) | Partly: darker and visible, but fewer and softer than "puffs" |
| 25 | A dotted dark-brown line about 230 px long, darkest at his boots, paler at its far end; separate puffs | A dark-brown dotted line behind him, clearly visible for about 135 px from his boots and fading out beyond that (2,084; 612; 87) | Yes, though the part that reads is shorter than the whole band |
| 40 | The same as frame 25 | The same line, a little more continuous (2,231; 670; 85) | Yes |
| 46 | A shorter, paler line of the oldest puffs, about 90 px | One pale patch about 40 px long near where he stopped (917; 152; 52) | Partly: shorter than predicted |
| 56 | Nothing | Nothing | Yes |

The measured targets at frame 25: 612 pixels changed by 20 levels or more, against at least 500 predicted (met), and a largest change of 87 levels, against at least 90 (just missed). Where it falls short, the likely reason is the same as before: the soft texture keeps each puff's edge transparent, and the oldest puffs fade towards the ground colour, so only the younger half of the band reads as dark. The trail is now visible in the enlarged frames as a dark-brown smudge in the grass behind his boots; whether it reads at real speed in the window is for my verdict.

**My verdict** (the preview, windowed at 1280 × 720, played three times at real speed after Claude's comparison): I can see it now, but there is still not enough dust, and it is not obvious enough. [现在能看到了，但我觉得尘土还不够多，还不够明显] **Kept** as the base for the next round, r2.

**Strips** (fixture captures; Movie Maker, 30 fps, 1280 × 720, seed 1, started by Claude at my request; only frames 10, 13, 25, 40, 46 and 56 are kept):
- `captures/run_dust/r0/` (`logs/capture_run_dust_r0.log`)
- `captures/run_dust/r1/`

**Commits:** `017e8a52` (the effect as the agent built it, unedited); then the commit of strip r0, and the commit of this round with strip r1.


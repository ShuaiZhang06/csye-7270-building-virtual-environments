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

**My verdict** (the preview, windowed at 1280 × 720, played three times at real speed after Claude's comparison): **kept**. I gave no further reason. The effect is not in the game yet (Step 3 wires it in), so this verdict is on the preview, not on play.

**Strips** (fixture captures; Movie Maker, 30 fps, 1280 × 720, seeds 1 and 2, started by Claude at my request; only frames 10, 12, 15, 20, 30 and 50 are kept):
- `captures/slash_sparks/r0/` (`logs/capture_slash_sparks_r0.log`)
- `captures/slash_sparks/r1/` (`logs/capture_slash_sparks_r1.log`)

**Commits:** `ea4419ae` (the effect as the agent built it, unedited); then the commit of strip r0, and the commit that makes this change with strip r1, this entry and the brief's Revision 3.

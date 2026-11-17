## Short answer

The r1 strip matches my prediction on every frame. Both logs show exactly the Grip values I predicted, and everything else is unchanged from r0. In the pictures, the stop after frame 32 is gone: the blade now keeps moving forward and slows down as it goes.

On your question: I read frames 34 and 35 as **a settle, not a new catch**. That is my claim from still images; your verdict in play decides. Nothing was changed or committed.

**How to read the angles.** "Screen" below is the blade's angle on screen, Grip minus the drawn −30.89°. Positive means below horizontal, because y points down. Rudy is small at 1280 × 720 and I couldn't enlarge the frames, so my visual angles are rough, to perhaps ±10°. The cropping was refused in the first session. This time a byte-for-byte comparison with r0 was refused too, so "same as r0" below means it looks the same and its log line is identical.

## `captures/slash/r1/` (J read on a frame's first tick)

| Frame | What I see | Log: tick, grip, lean, arc, live | My prediction | r0, same frame |
|---|---|---|---|---|
| 29 | Sword-idle Sprite, sword low at his side. Hitbox an outline. | –, sword_idle, live false | unchanged | Looks the same; log line identical. |
| 30 | The rig. Blade upright above his fist, tilted slightly back. Wide stance. No arc. Hitbox an outline. | 1, −67.50, −2.00, 0.000, false (screen −98°) | unchanged | Looks the same; log identical. |
| 31 | Blade still upright. Hitbox filled. | 3, −53.33, −0.33, 0.500, true | unchanged | Looks the same; log identical. |
| 32 | Blade points forward and well up. A pale arc crosses his body. He has moved forward a little. | 5, 0.00, 3.00, 0.857, true (screen −31°) | unchanged | Looks the same; log identical. |
| 33 | **Blade straight forward, about level.** It has clearly turned down since frame 32. Arc fainter. Hitbox filled. | 7, **25.00**, 3.00, 0.571, true (screen −6°) | **+25**, "well past F+2" | **Differs.** r0 had 5.00 here (screen −26°), almost the same picture as frame 32. That was the stall. |
| 34 | Blade forward, level to very slightly down. A little lower than frame 33. Arc barely visible. Hitbox filled. | 9, **40.00**, 3.00, 0.286, true (screen +9°) | **+40** | r0 didn't keep frame 34 (its log had 20.00). |
| 35 | Blade forward, slightly down. **Nearly the same as frame 34.** No arc. Hitbox back to an outline. | 11, 45.00, 3.00, 0.000, false (screen +14°) | unchanged, 5° past frame 34 | Looks the same; log identical. Only the frame before it changed. |
| 38 | Sword-idle Sprite, sword low. | 17, sword_idle, rig false | unchanged | Looks the same; log identical. |

**How far the blade turns per frame, frames 31→35:**
- r0: 53°, **5°**, 15°, 25°. The blade jumps, stops, then speeds up again.
- r1: 53°, **25°, 15°, 5°**. The blade jumps, then slows down steadily, as I predicted.

## `captures/slash/r1-second-tick/` (J read on a frame's second tick)

| Frame | What I see | Log: tick, grip, lean, arc, live | My prediction | r0, same frame |
|---|---|---|---|---|
| 29 | Sword-idle Sprite. | –, sword_idle | unchanged | Looks the same; log identical. |
| 30 | Blade upright, tilted back. Hitbox an outline. | 0, −70.00, −2.00, 0.000, false | unchanged | Looks the same; log identical. |
| 31 | Blade upright. Hitbox filled. | 2, −60.00, −2.00, 0.000, true | unchanged | Looks the same; log identical. |
| 32 | Blade forward and steeply up. Bright arc across the body. | 4, −33.33, 1.33, 1.000, true (screen −64°) | unchanged | Looks the same; log identical. |
| 33 | **Blade forward and a little up.** A big turn since frame 32. Arc fading. Hitbox filled. | 6, **13.75**, 3.00, 0.714, true (screen −17°) | **+13.75** | r0 didn't keep frame 33 (its log had 1.25, screen −30°). |
| 34 | **Blade level, straight forward.** Hitbox filled. | 8, **33.75**, 3.00, 0.429, true (screen +3°) | **+33.75**, past horizontal | r0 didn't keep frame 34 (its log had 11.25). |
| 35 | Blade forward, slightly down. Only a little lower than frame 34. Hitbox filled. | 10, **43.75**, 3.00, 0.143, true (screen +13°) | **+43.75** | **Differs.** r0's frame 35 (31.25, screen 0°) showed the blade level. |
| 36 | Blade level again: slightly higher than frame 35, a small move back. Hitbox an outline. | 12, 35.83, 2.08, 0.000, false (screen +5°) | unchanged; the blade now **pulls back** from frame 35 | Same picture and log as r0. In r0 it came after a level blade, so it read as a small move *forward* (31.25 → 35.83). Now it reads as a small move back (43.75 → 35.83). |
| 38 | Blade forward and up, arm still held out. Hitbox an outline. | 16, 15.83, 0.08, 0, false (screen −15°) | unchanged | Looks the same; log identical. |
| 39 | Sword-idle Sprite, sword low. | 18, sword_idle | unchanged | Looks the same; log identical. |

**How far the blade turns per frame, frames 32→36:**
- r0: 34.6°, 10°, 20°, 4.6° forward.
- r1: **47°, 20°, 10°, then −8° back**. The blade slows steadily and then reverses.

## Where the strip and my prediction agree, and where they don't

- **They agree on every logged number.** Both logs match my predicted Grip on every frame: 25.00 / 40.00 and 13.75 / 33.75 / 43.75. Lean, Lean position, the arc, the hitbox ticks and the clip position are the same as r0 on every frame. The pictures change only where the log changed.
- **One reading of mine was too generous.** I said frame 33 shows the blade "about 6° above horizontal". At this size it just reads as level; I can't make out the 6°.
- **Two changes I predicted can't be seen in these frames.**
  - The first-tick strip doesn't keep frame 36, so the move from the farthest point into the recovery (45 → 28.33, 17° back in one frame) isn't in it. In the log it is the fastest frame-to-frame change after frame 32, and the first to reverse direction.
  - The second-tick strip keeps no frame for tick 11, so its farthest point (+45) is never drawn. The nearest frames are 43.75 and 35.83.

## Frames 34 and 35: settle or catch?

**A settle**, for two reasons:
- **The slow frames are in the right place.** r0's catch was a stop in the middle of the swing: the blade jumped 53°, nearly stopped (5°), then sped up again (15°, 25°) in the same direction. In r1 the slow pair comes at the end of the forward motion, after a steady slowdown (53°, 25°, 15°, 5°). Nothing speeds up again in that direction. The blade comes to rest at its farthest pose and then goes back. That is the pattern of easing into an extreme pose, not of a hitch.
- **The second offset shows the same thing.** Frames 33→34→35 turn 20° and then 10°, and frame 36 moves back by 8°. Nowhere does the blade stop and then go on forward.

**Two caveats, so you know what to watch for in play:**
- **The second-tick strip has a near-hold of about 100 ms.** Frames 34, 35 and 36 all show the blade near level, within about 10°. At normal speed that could read as a hold at the end of the cut, or, if it's too long, as the blade hanging in front of him. I can't tell which from still images.
- **The hitbox is a little ahead of the blade.** In both strips the hitbox switches off between nearly identical pictures: first-tick frames 34→35, second-tick 35→36. The blade now arrives early and the window closes while it rests. That is the "hit lands, then settle" the reference suggests. I'm not proposing anything for it.

Everything above is my reading, a claim. Your verdict in the running game decides. I'm waiting for it.

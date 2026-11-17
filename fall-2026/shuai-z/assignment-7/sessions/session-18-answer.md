## Short answer

The motion follows the phase table on every tick: the startup, active and recovery ticks, the hitbox and the end cut. Where it departs is inside the active phase. The blade almost stops between ticks 5 and 7, and it reaches horizontal about two ticks later than the motion reference. I propose one change: the transition on the Grip key at 5/60 goes from 2.0 (ease-in) to 0.5 (ease-out). I have not edited anything.

## What each frame shows

I looked at each frame before reading its log line. Rudy is small at 1280 × 720 and my request to crop and enlarge the frames was refused, so these readings are rough, a few degrees at best.

### `captures/slash/r0/` (J read on a frame's first tick)

| Frame | What I see | Log line | Revision 5's table |
|---|---|---|---|
| 29 | Sword-idle Sprite, sword low at his side. Hitbox drawn as a faint outline. | `sword_idle`, live false | matches |
| 30 (F) | The rig. Blade upright above his fist, tilted slightly back. Stance wider, leaning back a little. No arc. Hitbox an outline. | tick 1, Grip −67.50, Lean −2, arc 0, live false | matches |
| 31 (F+1) | Blade **still upright**: almost the same picture as frame 30. The hitbox is now **filled**. I can't make out an arc. | tick 3, Grip −53.33, arc 0.5, live true | The numbers match. "Blade starting forward" is hard to see: the blade has turned only 14°. |
| 32 (F+2) | A big jump. Blade points forward, a little above horizontal. A pale arc crosses his body. He has moved forward a little. | tick 5, Grip 0, Lean 3, x 6, arc 0.857 | matches |
| 33 (F+3) | **Nearly the same as frame 32.** Blade in about the same place, arc fainter. | tick 7, Grip 5.00, arc 0.571 | Matches the table, which predicts this stall itself. |
| 35 (F+5) | Blade straight forward, tilted only **slightly** down. No arc. Hitbox an outline again. | tick 11, Grip 45, live false | The numbers match. "Forward and down" overstates it: +45° on the grip is only about 14° below horizontal on screen. |
| 38 (F+8) | Sword-idle Sprite, sword low. | `sword_idle`, rig false | matches |

### `captures/slash/r0-second-tick/` (J read on a frame's second tick)

| Frame | What I see | Log line | The log header's table |
|---|---|---|---|
| 30 | Blade upright and back, as in r0's frame 30. Hitbox an outline. | tick 0, Grip −70 | matches |
| 31 | Blade still upright. The hitbox is **filled**. | tick 2, Grip −60, live true | Matches, but the cut is live while the blade is still above his head. |
| 32 | Blade about 60° above horizontal, moving forward. Arc bright across the body. | tick 4, Grip −33.33, arc 1.0 | matches |
| 35 | Blade horizontal, pointing forward. Hitbox filled. | tick 10, Grip 31.25, live true | matches |
| 36 | Blade horizontal to slightly down: barely moved since frame 35. Hitbox an outline. | tick 12, Grip 35.83, live false | Matches. The blade's farthest point (+45 on tick 11) is in no frame. |
| 38 | Blade pointing forward and **up**, arm still held out. | tick 16, Grip 15.83 | matches |
| 39 | Sword-idle Sprite, sword low. | `sword_idle` | matches |

## Where the motion and the table disagree

**1. The blade nearly stops at tick 5.** This is the main finding, and the cause is in the keys. The Grip keys at 2/60 and at 5/60 both use transition 2.0 (`game/animations/rudy_animations.tres:417`). An ease-in starts from rest, so the blade arrives at 0° at its top speed (33°/tick) and then starts again from almost zero. The turn per tick across the active phase:
- before tick 5: 6.7°, 20°, 33.3°;
- after tick 5: **1.25°**, 3.75°, 6.25°, 8.75°, 11.25°, 13.75°.

In the r0 strip that shows as frame 31→32 turning 53°, then frame 32→33 only 5°. Revision 5's own table already predicts this ("almost where F+2 left it").

**2. The strike lands late against the motion reference.** Section 8 says horizontal should come about two-thirds of the way through the strike, around tick 8. With these keys, the blade is horizontal (Grip ≈ +30.9°) only at tick 9.97. That is the last live tick, so the fastest part of the sweep sits at the end of the hitbox window. Section 8 already named this as the first thing to tune.

**3. The hitbox goes live before the blade comes forward.** On ticks 2–4 the blade is still above his head while the hitbox is filled (r0 frame 31, second-tick frame 31). Revision 5 says the sweep "is drawn on the hitbox's ticks", and here it is not. My proposal leaves this as it is. I'm listing it for a later round.

**4. Smaller points:**
- **"Forward and down".** At +45° the blade is barely below horizontal on screen (r0 frame 35).
- **The end of the slash.** On tick 16 the blade is forward and up, with the arm out (second-tick frame 38). Then it cuts to the idle pose with the sword low. That is a visible pop. The cut itself is by design (section 3).
- **"The stall of Revision 4".** Revision 5's table cites this, but Revision 4 does not mention a stall.

## My reading against your verdict

You saw no catch in the sweep. My reading of frames 32 and 33 is the opposite: the blade stays almost in place for one frame, right after it moved 53° in one frame. That is a claim from two still images, not a check. Some reasons the two could differ:
- At normal speed, two near-identical 33 ms frames right after a big jump may read as a solid hit rather than a catch.
- Your verdict doesn't say which speed you watched at. At `--time-scale 0.25` it may be easier to see.
- The second-tick strip shows no stall, because frames 33 and 34 were not kept.

I agree with you that the three phases are distinct. Frame 30 is the startup, frames 31–33 the active phase, frames 35–37 the recovery.

## Proposal: one key's transition

On the Grip track, the key at 5/60 (0°) changes its transition from **2.0 (ease-in) to 0.5 (ease-out)**. The blade then leaves 0° fast and slows into +45° at tick 11, instead of restarting from rest. No key time, value, phase or gameplay timing changes.

Why this transition:
- It removes the stop at tick 5.
- It moves horizontal from tick 9.97 to tick 7.64, close to the reference's tick 8.
- It front-loads the strike, as the reference does: in the reference, the blade goes from vertical to horizontal in the first 4 of its 6 frames.

A linear transition would remove the stall too, but it puts horizontal at about tick 9.1 and does not front-load the strike. So I recommend ease-out.

## What the capture should show afterward

Grip, worked out with Godot's ease-out formula, 1 − (1 − x)². The same formula gives the 35.83 the second-tick log shows on tick 12.

**r0 (first-tick):** ticks 0–5 and 11–17 are unchanged (frames 29–32 and 35–38).

| Frame | Tick | Grip now | Grip after | What it should look like |
|---|---|---|---|---|
| 33 (F+3) | 7 | 5.00 | **25.00** | blade clearly past frame 32, about 6° above horizontal |
| 34 | 9 | 20.00 | **40.00** | blade just below horizontal (not a frame to read) |
| 35 (F+5) | 11 | 45.00 | 45.00 | **nearly the same as frame 34** |

- **Turn per frame:** frames 31→35 go from 53°, 5°, 15°, 25° to **53°, 25°, 15°, 5°**. The sweep then slows steadily.
- **The new slow pair.** Frames 34→35, ticks 9→11, now turn only 5°, so the slow frames move to the end of the active phase as an ease into the farthest pose. Whether that reads as a settle or as a new catch is for your eyes. I predict a settle.

**Second-tick:** frames 30–32 (ticks 0–4) and 36–39 (ticks 12–18) are unchanged.

| Frame | Tick | Grip now | Grip after |
|---|---|---|---|
| 33 | 6 | 1.25 | **13.75** |
| 34 | 8 | 11.25 | **33.75**, already horizontal |
| 35 | 10 | 31.25 | **43.75**, slightly down |

- **Frame 35 → 36.** The blade now visibly pulls back, from 43.75 to 35.83. Today it creeps forward, from 31.25 to 35.83.

**Unchanged in every frame:**
- Lean, Lean position and the arc's alpha;
- the hitbox, live on ticks 2–10;
- the rig appearing and disappearing, and the clip's position.

**Tests:**
- `test_rudy_clips.tscn`: still 51 PASS. Its check 2 expects the new transition, and the tick 3 and tick 16 samples don't move. No NEGATIVE line damages that transition.
- `test_rudy_states.tscn`: still 99. It samples the clip itself.
- `test_rudy_edges.tscn`: still 108 and 66. The blade still travels from −70° to +45°.

## The edit, once you approve

- `game/animations/rudy_animations.tres:417`: Grip transitions `(2, 2, 2, 0.5, 1)` become `(2, 2, 0.5, 0.5, 1)`.
- `game/tests/test_rudy_clips.gd:131`: `[5, 0.0, 2.0]` becomes `[5, 0.0, 0.5]`, and the comment at `:112-114` gets a line saying why.

**Left stale by the change, outside what you asked me to edit:**
- Revision 5's frame table, F+3 "+5", and its stall note;
- the header line that prints the same thing, `game/previews/slash_preview.gd:206`;
- the second-tick header's tick 10 value, `game/previews/slash_preview.gd:219`.

These expected values would no longer match the capture. Say whether the approval covers them, or whether a brief revision follows separately. Nothing is approved yet, so I've stopped here.

I wrote the edge test (step 5b), and it passes at both rates: 98 of 98 checks at 60 fps and 66 of 66 at 30 fps. Two runs at each rate gave identical EDGES and RESULT lines. No edge failed. One problem came from the test's own input method at 30 fps; it is under ANOMALIES below. I changed no other file and committed nothing. Godot did not write a `.uid` for the script: `game/tests/` holds only `test_rudy_edges.gd` and `test_rudy_edges.tscn`.

## How the test follows the state test's rules

- **The real Main.** Every scenario starts a fresh Main with the title skipped. Setup only places Rudy and lets him settle for 20 ticks. He takes the sword by walking into the pickup.
- **Input.** Only key events for D, A, Space, J and Esc go through `Input.parse_input_event`. A fresh press of a key that is still held sends its key-up and key-down together, as the pin does.
- **Reads only.** The test reads properties (including `_slash_clock`), `is_on_floor()`, `get_children()`, the player's `current_animation` and `current_animation_position`, and Input's just-pressed and just-released flags. It never calls `play()`, `seek()`, `advance()` or a state method.
- **The recorder** is the scene's root node, with `process_physics_priority = 100`. It runs after Rudy, his player and the effects driver, so sample N is what tick N left. It also logs which tick of its frame each sample is (slot a or b) and whether the tree was paused.
- **Running through the pause:**
  - The root node's `process_mode` is ALWAYS, set in the `.tscn`, so it keeps sampling every tick while paused and marks those ticks as paused.
  - The test steps itself by awaiting the scene tree's `process_frame` and `physics_frame` signals, which the tree still emits while paused.
  - Main goes under the tree's root, not under the test node, so it inherits the root's pausable mode as it does in the game. Under an ALWAYS parent it would never pause.
- **Frame rate.** The test measures ticks per frame over 10 frames: 1 runs E1–E7, and 2 runs E1 and E2 at both offsets.

## `scripts/run-test.sh test_rudy_edges.tscn 60`

The block below is from the 60 fps run I printed in full, on the final code. I then ran it twice more and saved the lines to files. `diff` found those two runs identical, both ending `RESULT PASS: 98 checks, 0 failed, 5225 ticks, 60 fps`.

```
== EDGES ==
PASS  ALL @60 fps [-]: ticks per frame measured: 1, so E1-E7 run
PASS  ALL @60 fps [-]: every scripted wait was met
PASS  E1 @60 fps [E1]: every key event was read on the tick it was sent for  (11 events; wrong: [])
PASS  E1 @60 fps [E1]: swing A: presses read on swing ticks [1, 10, 16], the swing's own on 0  (read on swing ticks 0, 1, 10, 16, 18)
PASS  E1 @60 fps [E1]: swing A, presses ignored: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @60 fps [E1]: swing A, presses ignored: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @60 fps [E1]: swing A, presses ignored: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 0>1 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @60 fps [E1]: swing A, presses ignored: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @60 fps [E1]: the press read on swing tick 18 starts swing B  (tick 18: in [J+J-], sounds 1>2)
PASS  E1 @60 fps [E1]: swing B: presses read on swing ticks [2, 11, 17]  (read on swing ticks 0, 2, 11, 17)
PASS  E1 @60 fps [E1]: swing B (the new swing, presses ignored): on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @60 fps [E1]: swing B (the new swing, presses ignored): hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @60 fps [E1]: swing B (the new swing, presses ignored): one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 1>2 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @60 fps [E1]: swing B (the new swing, presses ignored): on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @60 fps [E1]: swing B starts from clip time 0: Grip -70 deg on tick 0, 45 deg on tick 11, travel at least 100 deg  (Grip -70.00 on tick 0, 45.00 on tick 11, -70.00 to 45.00: 115.00 deg; Grip on swing A's last tick 15.83)
PASS  E2 @60 fps [E2]: every key event was read on the tick it was sent for  (18 events; wrong: [])
PASS  E2 @60 fps [E2]: jump on swing tick 1: read on that tick, and he takes off on it  (Space read on swing tick(s) 1; tick 1: vy -1500.0, floor 0 (tick 0 floor 1), jump sounds 0>1)
PASS  E2 @60 fps [E2]: jump on swing tick 1: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @60 fps [E2]: jump on swing tick 1: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @60 fps [E2]: jump on swing tick 1: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 2>3 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @60 fps [E2]: jump on swing tick 1: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @60 fps [E2]: jump on swing tick 1: the swing plays on in the air from tick 1 to its end  (on the floor on: [])
PASS  E2 @60 fps [E2]: jump on swing tick 5: read on that tick, and he takes off on it  (Space read on swing tick(s) 5; tick 5: vy -1500.0, floor 0 (tick 4 floor 1), jump sounds 1>2)
PASS  E2 @60 fps [E2]: jump on swing tick 5: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @60 fps [E2]: jump on swing tick 5: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @60 fps [E2]: jump on swing tick 5: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 3>4 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @60 fps [E2]: jump on swing tick 5: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @60 fps [E2]: jump on swing tick 5: the swing plays on in the air from tick 5 to its end  (on the floor on: [])
PASS  E2 @60 fps [E2]: jump on swing tick 12: read on that tick, and he takes off on it  (Space read on swing tick(s) 12; tick 12: vy -1500.0, floor 0 (tick 11 floor 1), jump sounds 2>3)
PASS  E2 @60 fps [E2]: jump on swing tick 12: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @60 fps [E2]: jump on swing tick 12: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @60 fps [E2]: jump on swing tick 12: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 4>5 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @60 fps [E2]: jump on swing tick 12: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @60 fps [E2]: jump on swing tick 12: the swing plays on in the air from tick 12 to its end  (on the floor on: [])
PASS  E2 @60 fps [E2]: slash in the air, read 33 ticks after the jump: he lands during the swing (swing ticks 1-16)  (press read 33 ticks after the jump; lands on swing tick 8)
PASS  E2 @60 fps [E2]: slash in the air, read 33 ticks after the jump, landing does not cut it: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @60 fps [E2]: slash in the air, read 33 ticks after the jump, landing does not cut it: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @60 fps [E2]: slash in the air, read 33 ticks after the jump, landing does not cut it: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 5>6 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @60 fps [E2]: slash in the air, read 33 ticks after the jump, landing does not cut it: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E3 @60 fps [E3-rehearsal]: every key event was read on the tick it was sent for  (4 events; wrong: [])
PASS  E3 @60 fps [E3-rehearsal]: goblin B's hit on the standing Rudy, from behind: its st, replayed in E3's runs  (hit on st 574; facing -1 > 1 (he turns toward the hit, which came from his back))
PASS  E3 @60 fps [E3-k1]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k1]: hit on swing tick 1 (startup): the hit lands on that swing tick, from behind  (swing starts on st 573, hit on swing tick 1; facing before the hit -1)
PASS  E3 @60 fps [E3-k1]: hit on swing tick 1 (startup): on the tick before it the swing is under way at clip time 0/60  (tick 0: slash pos 0.0000 rig 1 spr 0)
PASS  E3 @60 fps [E3-k1]: hit on swing tick 1 (startup): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 1: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k1]: hit on swing tick 1 (startup): hitbox never live; 0 spark burst(s) before the hit, none from the hit on  (live on []; bursts started before the hit 0, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k2]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k2]: hit on swing tick 2 (active): the hit lands on that swing tick, from behind  (swing starts on st 572, hit on swing tick 2; facing before the hit -1)
PASS  E3 @60 fps [E3-k2]: hit on swing tick 2 (active): on the tick before it the swing is under way at clip time 1/60  (tick 1: slash pos 0.0167 rig 1 spr 0)
PASS  E3 @60 fps [E3-k2]: hit on swing tick 2 (active): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 2: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k2]: hit on swing tick 2 (active): hitbox never live; 0 spark burst(s) before the hit, none from the hit on  (live on []; bursts started before the hit 0, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k6]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k6]: hit on swing tick 6 (active): the hit lands on that swing tick, from behind  (swing starts on st 568, hit on swing tick 6; facing before the hit -1)
PASS  E3 @60 fps [E3-k6]: hit on swing tick 6 (active): on the tick before it the swing is under way at clip time 5/60  (tick 5: slash pos 0.0833 rig 1 spr 0)
PASS  E3 @60 fps [E3-k6]: hit on swing tick 6 (active): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 6: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k6]: hit on swing tick 6 (active): hitbox live only on swing ticks 2-5 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k10]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k10]: hit on swing tick 10 (active): the hit lands on that swing tick, from behind  (swing starts on st 564, hit on swing tick 10; facing before the hit -1)
PASS  E3 @60 fps [E3-k10]: hit on swing tick 10 (active): on the tick before it the swing is under way at clip time 9/60  (tick 9: slash pos 0.1500 rig 1 spr 0)
PASS  E3 @60 fps [E3-k10]: hit on swing tick 10 (active): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 10: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k10]: hit on swing tick 10 (active): hitbox live only on swing ticks 2-9 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5, 6, 7, 8, 9]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k11]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k11]: hit on swing tick 11 (recovery): the hit lands on that swing tick, from behind  (swing starts on st 563, hit on swing tick 11; facing before the hit -1)
PASS  E3 @60 fps [E3-k11]: hit on swing tick 11 (recovery): on the tick before it the swing is under way at clip time 10/60  (tick 10: slash pos 0.1667 rig 1 spr 0)
PASS  E3 @60 fps [E3-k11]: hit on swing tick 11 (recovery): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 11: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k11]: hit on swing tick 11 (recovery): hitbox live only on swing ticks 2-10 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k16]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): the hit lands on that swing tick, from behind  (swing starts on st 558, hit on swing tick 16; facing before the hit -1)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): on the tick before it the swing is under way at clip time 15/60  (tick 15: slash pos 0.2500 rig 1 spr 0)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 16: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): hitbox live only on swing ticks 2-10 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E4 @60 fps [E4]: every key event was read on the tick it was sent for  (4 events; wrong: [])
PASS  E4 @60 fps [E4]: the slash shows at once over the run: swing tick 0 is slash at 0, SlashRig shown  (tick -1: sword_run pos 0.1833 CHAR-SWORD-RUN-B; tick 0: slash pos 0.0000 CHAR-SWORD-SLASH rig 1 spr 0)
PASS  E4 @60 fps [E4]: the swing over the run: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E4 @60 fps [E4]: the swing over the run: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E4 @60 fps [E4]: the swing over the run: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 12>13 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E4 @60 fps [E4]: the swing over the run: on swing tick 17 the swing is over and sword_run shows, the Sprite back  (tick 17: sword_run, CHAR-SWORD-RUN-A, clock -1.0000, spr 1 rig 0)
PASS  E4 @60 fps [E4]: after the swing sword_run restarts: SWORD-RUN-A on swing ticks 17-24 at 0..7/60 s, SWORD-RUN-B on 25  (wrong: []; before the press it stood at 0.1833 s (CHAR-SWORD-RUN-B))
PASS  E4 @60 fps [E4]: D held throughout: he runs at full speed on the floor from tick -1 to 25  (wrong: [])
PASS  E5 @60 fps [E5]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E5 @60 fps [E5]: the turn is read on swing tick 5, in the active phase  (A read on swing tick(s) 5; hitbox live on 4 and 5: true)
PASS  E5 @60 fps [E5]: on the turn's tick Look and the rig flip, and the hitbox moves to his other side  (tick 4: facing 1, Look scale.x 1, rig x axis 1, hitbox +50.0 px; tick 5: facing -1, Look -1, rig -1, hitbox -50.0 px)
PASS  E5 @60 fps [E5]: it stays turned to the swing's end  (wrong on: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 13>14 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E6 @60 fps [E6]: every key event was read on the tick it was sent for  (8 events; wrong: [])
PASS  E6 @60 fps [E6]: Esc read on swing tick 5 pauses the tree after that tick; one pause, 31 ticks long  (Esc read on swing tick(s) 5; the last game tick before the pause is swing tick 5; paused from st 31 to 61; unpaused inside: [])
PASS  E6 @60 fps [E6]: while paused the clip position and the swing clock stay put (0.0833 s, 0.1000 s)  (31 paused ticks; changed on: [])
PASS  E6 @60 fps [E6]: on resume both go on from where they stopped: the first game tick after the pause is swing tick 6  (st 62: pos 0.1000, clock 0.1167)
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 14>15 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E7 @60 fps [E7]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E7 @60 fps [E7]: he stays in run through both taps: on the floor, moving, every tick st 0-44  (not running on: []; D- read on st 20: true, D+ on st 21: true, vx there 466.7; D- read on st 31: true, D+ on st 32: true, vx there 466.7)
PASS  E7 @60 fps [E7]: the run clip is never restarted: from st 0 its position is (ticks since st 0)/60 mod 0.25 on every tick  (wrong: [])
RESULT PASS: 98 checks, 0 failed, 5225 ticks, 60 fps
```

## `scripts/run-test.sh test_rudy_edges.tscn 30`, run 1

This is the saved file's content. Run 2's file is identical (`diff` printed nothing), with the same `RESULT PASS: 66 checks, 0 failed, 642 ticks, 30 fps`.

```
== EDGES ==
PASS  ALL @30 fps [-]: ticks per frame measured: 2, so E1 and E2 run at both offsets
PASS  ALL @30 fps [-]: every scripted wait was met
PASS  E1 @30 fps, offset first [E1-first]: every key event was read on the tick it was sent for  (11 events; wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C: its own press read in slot b, a press read on its swing tick 1 in slot a  (read on swing ticks 0 (b), 1 (a))
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 2>3 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset first [E1-first]: swing A: presses read on swing ticks [2, 10, 16], the swing's own on 0  (read on swing ticks 0 (a), 2 (a), 10 (a), 16 (a), 18 (a))
PASS  E1 @30 fps, offset first [E1-first]: swing A, presses ignored: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing A, presses ignored: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset first [E1-first]: swing A, presses ignored: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 0>1 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset first [E1-first]: swing A, presses ignored: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset first [E1-first]: the press read on swing tick 18 starts swing B  (tick 18: in [J+J-], sounds 1>2)
PASS  E1 @30 fps, offset first [E1-first]: swing B (the new swing): on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing B (the new swing): hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset first [E1-first]: swing B (the new swing): one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 1>2 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset first [E1-first]: swing B (the new swing): on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset first [E1-first]: swing B starts from clip time 0: Grip -70 deg on tick 0, 45 deg on tick 11, travel at least 100 deg  (Grip -70.00 on tick 0, 45.00 on tick 11, -70.00 to 45.00: 115.00 deg; Grip on swing A's last tick 15.83)
PASS  E2 @30 fps, offset first [E2-first]: every key event was read on the tick it was sent for  (10 events; wrong: [])
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: read on that tick, and he takes off on it  (Space read on swing tick(s) 12 (a); tick 12: vy -1500.0, floor 0 (tick 11 floor 1), jump sounds 0>1)
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 3>4 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @30 fps, offset first [E2-first]: jump on swing tick 12: the swing plays on in the air from tick 12 to its end  (on the floor on: [])
PASS  E2 @30 fps, offset first [E2-first]: slash in the air, read 32 ticks after the jump: he lands during the swing (swing ticks 1-16)  (press read 32 ticks after the jump (slot a); lands on swing tick 9)
PASS  E2 @30 fps, offset first [E2-first]: slash in the air, read 32 ticks after the jump, landing does not cut it: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @30 fps, offset first [E2-first]: slash in the air, read 32 ticks after the jump, landing does not cut it: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @30 fps, offset first [E2-first]: slash in the air, read 32 ticks after the jump, landing does not cut it: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 4>5 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @30 fps, offset first [E2-first]: slash in the air, read 32 ticks after the jump, landing does not cut it: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset second [E1-second]: every key event was read on the tick it was sent for  (9 events; wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (method limit, measured): J sent for slot a of tick 0 and a slot-b J for tick 1 merge into one press, read on tick 1, which starts the swing  (tick 0: in [] sword_idle; tick 1 (slot b): in [J+J-] slash pos 0.0000, sounds 5>6)
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 5>6 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset second [E1-second]: swing A: presses read on swing ticks [11, 17], the swing's own on 0  (read on swing ticks 0 (a), 11 (b), 17 (b), 19 (b))
PASS  E1 @30 fps, offset second [E1-second]: swing A, presses ignored: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing A, presses ignored: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset second [E1-second]: swing A, presses ignored: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 6>7 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset second [E1-second]: swing A, presses ignored: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset second [E1-second]: the press read on swing tick 19 starts swing B  (tick 19: in [J+J-], sounds 7>8)
PASS  E1 @30 fps, offset second [E1-second]: swing B (the new swing): on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing B (the new swing): hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset second [E1-second]: swing B (the new swing): one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 7>8 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset second [E1-second]: swing B (the new swing): on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset second [E1-second]: swing B starts from clip time 0: Grip -70 deg on tick 0, 45 deg on tick 11, travel at least 100 deg  (Grip -70.00 on tick 0, 45.00 on tick 11, -70.00 to 45.00: 115.00 deg; Grip on swing A's last tick 15.83)
PASS  E2 @30 fps, offset second [E2-second]: every key event was read on the tick it was sent for  (14 events; wrong: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: read on that tick, and he takes off on it  (Space read on swing tick(s) 1 (b); tick 1: vy -1500.0, floor 0 (tick 0 floor 1), jump sounds 2>3)
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 8>9 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 1: the swing plays on in the air from tick 1 to its end  (on the floor on: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: read on that tick, and he takes off on it  (Space read on swing tick(s) 5 (b); tick 5: vy -1500.0, floor 0 (tick 4 floor 1), jump sounds 3>4)
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 9>10 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: on swing tick 17 the swing is over and sword_rise or sword_fall shows, the Sprite back  (tick 17: sword_rise, CHAR-SWORD-RISE, clock -1.0000, spr 1 rig 0)
PASS  E2 @30 fps, offset second [E2-second]: jump on swing tick 5: the swing plays on in the air from tick 5 to its end  (on the floor on: [])
PASS  E2 @30 fps, offset second [E2-second]: slash in the air, read 33 ticks after the jump: he lands during the swing (swing ticks 1-16)  (press read 33 ticks after the jump (slot b); lands on swing tick 8)
PASS  E2 @30 fps, offset second [E2-second]: slash in the air, read 33 ticks after the jump, landing does not cut it: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E2 @30 fps, offset second [E2-second]: slash in the air, read 33 ticks after the jump, landing does not cut it: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E2 @30 fps, offset second [E2-second]: slash in the air, read 33 ticks after the jump, landing does not cut it: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 10>11 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E2 @30 fps, offset second [E2-second]: slash in the air, read 33 ticks after the jump, landing does not cut it: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
RESULT PASS: 66 checks, 0 failed, 642 ticks, 30 fps
```

## Which swing ticks were reached at 30 fps

I read "offset" as the slot of the edge's own presses. If every press, including the one that starts the swing, sat in the same slot, the edge presses would only ever land on even swing ticks at both offsets. So each swing's own J is read in slot a, and the edge presses go in slot a (even swing ticks) or slot b (odd ones).

| Named tick | Where it was read |
|---|---|
| E1: 2, 10, 16, 18 | offset first, slot a |
| E1: 11, 17 | offset second, slot b. The new swing after it starts on tick 19, the earliest slot-b tick after the swing (18 is always slot a) |
| E1: 1 | only in slot a, in swing C, whose own J is read in slot b. **Tick 1 in slot b cannot be reached** after the swing's own J in slot a (see ANOMALIES) |
| E2: 12 | slot a |
| E2: 1, 5 | slot b (Space works there, because it is a different key from J) |

So every tick E1 and E2 name was read at 30 fps.

## ANOMALIES

**No edge failed** at 60 or 30. One case is kept as measured and classified as **an error in the test's method, not a bug in the game**:

- I sent the swing's own J for slot a of tick 0, and a slot-b J for tick 1 by the brief's method (await `physics_frame`, then the event, then `flush_buffered_events()`).
- The flush comes after tick 0's `physics_frame` signal but before Rudy reads tick 0. It re-stamps the first J, so the two presses merge into one, read on tick 1, and the swing starts there.
- In my first 30 fps run this made five checks fail. The test now keeps the case as swing M, with a check that pins the merge, and prints it under ANOMALIES with these lines:

```
ANOMALY (measured, kept) E1 @30 fps, offset second [E1-second], swing M: a J press on swing tick 1 in slot b cannot follow the swing's own J in slot a of the same frame; the two merge into one press read on tick 1. Error in the test's method, not the game: tick 1 is reached in the first offset (swing C)
  tick   371 E1-second     st   26 a   PLAY        sword_idle pos 0.1833 clk -1.0000 CHAR-SWORD-IDLE  spr 1 rig 0 grip    0.00 face  1 look  1 rigx  1 hb +50.0 dis 1 v(    0.0,    0.0) floor 1 gear 1 hp 3 x  2493.3 burst+0 in -
  tick   372 E1-second     st   27 b   PLAY        slash      pos 0.0000 clk  0.0167 CHAR-SWORD-SLASH spr 0 rig 1 grip  -70.00 face  1 look  1 rigx  1 hb +50.0 dis 1 v(    0.0,    0.0) floor 1 gear 1 hp 3 x  2493.3 burst+0 in J+J-
```

A side note on the logs: `J+J-` on a single tick is the key-up and key-down sent together, which raises both input flags on that tick. It is not two presses.

## Earlier tests

- **`scripts/run-test.sh test_rudy_pin.tscn 60`:** `RESULT FAIL: 19 checks, 3 failed, 953 ticks`. That is still 16 of 19, with T1, T2 and T6 failing as committed in step 2b.
- **`scripts/run-test.sh checks.tscn 60`:** its last line before the engine's exit warnings is `all checks passed` (141 PASS, 0 FAIL). The res:// line reads `PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )`, so the count is 98, as you expected.

## `git status`

```
On branch shuai-z/assignment-7
You are in a sparse checkout with 52% of the tracked files present.

Changes not staged for commit:
	modified:   logs/checks_60fps.log

Untracked files:
	game/tests/test_rudy_edges.gd
	game/tests/test_rudy_edges.tscn
	logs/test_rudy_edges_30fps.log
	logs/test_rudy_edges_60fps.log
	sessions/prompt-10.txt
```

The pin's log was rewritten with identical content, so it does not show as changed.

## The scenarios

"st" is in physics ticks from the scenario's first key. "kN" is swing tick N. Releases are left out unless they matter. Each sword scenario is placed at x 2400. He holds D into the pickup at x 2500 and stops at x 2484 (at 30 fps, 2493), facing right, before the edge.

| Scenario | Rate, offset | Starts at | Keys, on which ticks |
|---|---|---|---|
| E1 | 60 | x 2400 → stands with the sword at x 2484 | D@0–9; J@25 (swing A, k0); J re-pressed on A's k1, k10, k16; J on k18 (st 43) starts swing B; J on B's k2, k11, k17 |
| E2 | 60 | same | J@25 + Space on k1; J@78 + Space on k5; J@135 + Space on k12; then Space@199 (jump in place) + J@232 (33 ticks later, lands on k8) |
| E3-rehearsal | 60 | x 2400; D@0 to x ≥ 2945 (D up at 61), A tap@76 faces him away from goblin B | none after that; goblin B's hit lands on st 574 |
| E3-k1, k2, k6, k10, k11, k16 | 60 | the rehearsal's keys, replayed | J@574−k, so the hit lands on swing tick k (from behind) |
| E4 | 60 | x 2400, D held from 0 (sword at st 8, sword_run on cell B at the press) | J@20; D held to st 57 |
| E5 | 60 | stands with the sword at x 2484 | J@25; A tap on k5 (st 30) |
| E6 | 60 | same | J@25; Esc on k5 (st 30); 30 frames paused; Esc@61 |
| E7 | 60 | the StartPoint, x 300, no sword | D@0; D released on st 20 and 31, pressed again on 21 and 32; D up@45 |
| E1-first | 30, first | stands with the sword at x 2493 | J@26 (a); J on k2, k10, k16 (a); k18 (a) starts swing B; swing C: own J@75 (b), J on its k1 (a) |
| E2-first | 30, first | same | J@26 (a) + Space on k12 (a); Space@90 + J@122 (32 ticks later, a; lands on k9) |
| E1-second | 30, second | same | swing M: J sent for st 26 (a) + J for 27 (b), which merge; swing A: J@56 (a), J on k11, k17 (b); k19 (b) starts swing B |
| E2-second | 30, second | same | J@26 (a) + Space on k1 (b); J@80 (a) + Space on k5 (b); Space@138 + J@171 (33 ticks later, b; lands on k8) |

## Step 5m: which broken version each edge's checks should fail on

None of these has been run.

- **E1:** a one-line break in `rudy.gd`'s slash condition: delete `not is_slashing() and`. E1 would then get a sound on k1, the clock reset, and no hitbox window on 2–10.
  - Revision 4's play()-before-seek() order also fails E1, as it does every edge that checks a whole swing: the clip stops on tick 16.
  - Dropping the restart flag (`play_clip(_pick_clip(), false)`) would **not** fail E1. A new swing always follows a tick of `sword_idle`, which the brief already notes, so it does not test failure 4 of section 10.
- **E2:** gate the jump on the swing: `elif in_control and not is_slashing() and Input.is_action_just_pressed(&"jump"):`. The takeoff check fails. To test the landing case instead, put `is_on_floor() and` in front of `is_slashing()` in `_pick_clip()`.
- **E3:** delete `_slash_clock = -1.0` in `take_hit()` (`rudy.gd:143`). The hitbox stays live after the hit, a spark burst starts after it for k1 and k2, and the clock is not below 0.
- **E4:**
  - **On 3908ae80 the edge test cannot run its checks.** There is no `Look/AnimationPlayer` or `SlashRig` there, so it stops on a SCRIPT ERROR, which fails the wrapper but proves nothing about the resume.
  - For the restart check I suggest a three-line break in `rudy_look.gd`: store the run's position when it leaves `sword_run`, and seek back to it.
  - For "the slash shows at once": `if is_slashing() and absf(velocity.x) <= 1.0:` in `_pick_clip()`.
- **E5:** delete `_sword_box.position.x = slash_reach * facing` in `_swing()`. The hitbox stays on his right after the turn. Or delete `_look.scale.x = facing`, and Look and the rig do not flip.
- **E6:** set `process_mode = 3` (ALWAYS) on `Look/AnimationPlayer` in `rudy.tscn`. The clip runs on while paused and the swing clock does not, so "while paused … stay put" fails.
- **E7:** `_look.play_clip(_pick_clip(), new_swing or Input.is_action_just_pressed(&"move_right"))`. Pressing D again restarts the run clip, and the position check fails on st 21.

## What still needs a human to play

- **What each 30 fps frame shows.** This test checks ticks, not rendered frames: for example a press on the second tick of a frame, and whether the swing's wind-up shows at all.
- **Whether the cuts read on screen:** the rig vanishing into `hurt` (E3), the flip mid-swing (E5), and landing during a slash (E2).
- **The pause screen with the rig frozen** (E6), and that resuming does not pop.
- **Whether a re-press during a swing feels ignored or lost** (E1), and how soon the earliest next swing (tick 18) feels.
- **Real keys:** key repeat and very fast taps, which `parse_input_event` does not produce.
- **The spark bursts on screen,** none after a hit.
- **Running step 5m's mutations** in a worktree.

Nothing is committed.
I added swing ticks 3 and 12 to E1 and E3, and every new check passes. The 60 fps edge test now has 108 checks (10 new) and the 30 fps run still has 66; both runs at each rate agree. No game file changed. The `.tscn` didn't need to change, and nothing is committed.

## What changed

**`game/tests/test_rudy_edges.gd`**, three edits:
- **Header:** a Step 5c paragraph saying which presses and hits were added, and that nothing else changed.
- **E1:**
  - At 60, swing A now takes 1, 3, 10, 12 and 16, so it has the tick before and the tick after each boundary. No two presses fall on neighbouring ticks. Swing B keeps 2, 11 and 17.
  - At 30, the first offset's presses become 2, 10, 12, 16 (slot a). The second offset's become 3, 11, 17 (slot b).
- **E3:** `E3_HIT_TICKS` becomes `[1, 2, 3, 6, 10, 11, 12, 16]`. Hit 6 stays.

Why E1 adds no checks: its existing checks already cover every tick of each swing, plus "presses read on swing ticks [...]". The new presses just go through those same checks. E3 adds 5 checks for each of its two new runs.

**`CLAUDE.md`:** the 60 fps line now reads `108 PASS (logs/test_rudy_edges_60fps.log:6679)`. The 30 fps line still reads `66 PASS (…:734)`: the count is the same and the RESULT line is still at 734.

## `scripts/run-test.sh test_rudy_edges.tscn 60`, run 1

```
== EDGES ==
PASS  ALL @60 fps [-]: ticks per frame measured: 1, so E1-E7 run
PASS  ALL @60 fps [-]: every scripted wait was met
PASS  E1 @60 fps [E1]: every key event was read on the tick it was sent for  (13 events; wrong: [])
PASS  E1 @60 fps [E1]: swing A: presses read on swing ticks [1, 3, 10, 12, 16], the swing's own on 0  (read on swing ticks 0, 1, 3, 10, 12, 16, 18)
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
PASS  E3 @60 fps [E3-k3]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k3]: hit on swing tick 3 (active): the hit lands on that swing tick, from behind  (swing starts on st 571, hit on swing tick 3; facing before the hit -1)
PASS  E3 @60 fps [E3-k3]: hit on swing tick 3 (active): on the tick before it the swing is under way at clip time 2/60  (tick 2: slash pos 0.0333 rig 1 spr 0)
PASS  E3 @60 fps [E3-k3]: hit on swing tick 3 (active): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 3: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k3]: hit on swing tick 3 (active): hitbox live only on swing ticks 2-2 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
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
PASS  E3 @60 fps [E3-k12]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k12]: hit on swing tick 12 (recovery): the hit lands on that swing tick, from behind  (swing starts on st 562, hit on swing tick 12; facing before the hit -1)
PASS  E3 @60 fps [E3-k12]: hit on swing tick 12 (recovery): on the tick before it the swing is under way at clip time 11/60  (tick 11: slash pos 0.1833 rig 1 spr 0)
PASS  E3 @60 fps [E3-k12]: hit on swing tick 12 (recovery): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 12: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k12]: hit on swing tick 12 (recovery): hitbox live only on swing ticks 2-10 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E3 @60 fps [E3-k16]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): the hit lands on that swing tick, from behind  (swing starts on st 558, hit on swing tick 16; facing before the hit -1)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): on the tick before it the swing is under way at clip time 15/60  (tick 15: slash pos 0.2500 rig 1 spr 0)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead  (tick 16: mode HURT, hurt pos 0.0000, CHAR-HURT, spr 1 rig 0, hitbox disabled 1, clock -1.0000, gear 0)
PASS  E3 @60 fps [E3-k16]: hit on swing tick 16 (recovery): hitbox live only on swing ticks 2-10 before the hit, never after; 1 spark burst(s) before the hit, none from the hit on  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10]; bursts started before the hit 1, on or after it [] over 52 ticks; slash sounds after 0)
PASS  E4 @60 fps [E4]: every key event was read on the tick it was sent for  (4 events; wrong: [])
PASS  E4 @60 fps [E4]: the slash shows at once over the run: swing tick 0 is slash at 0, SlashRig shown  (tick -1: sword_run pos 0.1833 CHAR-SWORD-RUN-B; tick 0: slash pos 0.0000 CHAR-SWORD-SLASH rig 1 spr 0)
PASS  E4 @60 fps [E4]: the swing over the run: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E4 @60 fps [E4]: the swing over the run: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E4 @60 fps [E4]: the swing over the run: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 14>15 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E4 @60 fps [E4]: the swing over the run: on swing tick 17 the swing is over and sword_run shows, the Sprite back  (tick 17: sword_run, CHAR-SWORD-RUN-A, clock -1.0000, spr 1 rig 0)
PASS  E4 @60 fps [E4]: after the swing sword_run restarts: SWORD-RUN-A on swing ticks 17-24 at 0..7/60 s, SWORD-RUN-B on 25  (wrong: []; before the press it stood at 0.1833 s (CHAR-SWORD-RUN-B))
PASS  E4 @60 fps [E4]: D held throughout: he runs at full speed on the floor from tick -1 to 25  (wrong: [])
PASS  E5 @60 fps [E5]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E5 @60 fps [E5]: the turn is read on swing tick 5, in the active phase  (A read on swing tick(s) 5; hitbox live on 4 and 5: true)
PASS  E5 @60 fps [E5]: on the turn's tick Look and the rig flip, and the hitbox moves to his other side  (tick 4: facing 1, Look scale.x 1, rig x axis 1, hitbox +50.0 px; tick 5: facing -1, Look -1, rig -1, hitbox -50.0 px)
PASS  E5 @60 fps [E5]: it stays turned to the swing's end  (wrong on: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 15>16 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E5 @60 fps [E5]: the swing through the turn, neither clip nor hitbox window restarted: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E6 @60 fps [E6]: every key event was read on the tick it was sent for  (8 events; wrong: [])
PASS  E6 @60 fps [E6]: Esc read on swing tick 5 pauses the tree after that tick; one pause, 31 ticks long  (Esc read on swing tick(s) 5; the last game tick before the pause is swing tick 5; paused from st 31 to 61; unpaused inside: [])
PASS  E6 @60 fps [E6]: while paused the clip position and the swing clock stay put (0.0833 s, 0.1000 s)  (31 paused ticks; changed on: [])
PASS  E6 @60 fps [E6]: on resume both go on from where they stopped: the first game tick after the pause is swing tick 6  (st 62: pos 0.1000, clock 0.1167)
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 16>17 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E6 @60 fps [E6]: the swing counted in game ticks across the pause, no tick lost or repeated: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E7 @60 fps [E7]: every key event was read on the tick it was sent for  (6 events; wrong: [])
PASS  E7 @60 fps [E7]: he stays in run through both taps: on the floor, moving, every tick st 0-44  (not running on: []; D- read on st 20: true, D+ on st 21: true, vx there 466.7; D- read on st 31: true, D+ on st 32: true, vx there 466.7)
PASS  E7 @60 fps [E7]: the run clip is never restarted: from st 0 its position is (ticks since st 0)/60 mod 0.25 on every tick  (wrong: [])
== ANOMALIES ==
none
RESULT PASS: 108 checks, 0 failed, 6517 ticks, 60 fps
```

**Run 2:** `RESULT PASS: 108 checks, 0 failed, 6517 ticks, 60 fps`. `diff` of the two full outputs printed one difference, in the engine's exit warning:
```
6680c6680
< WARNING: 17 ObjectDB instances were leaked at exit (run with `--verbose` for details).
---
> WARNING: 16 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```
Every per-tick line, EDGES line and RESULT line is the same in both runs.

## `scripts/run-test.sh test_rudy_edges.tscn 30`, run 2

Both runs printed identical EDGES and RESULT lines. This block is run 2's:

```
== EDGES ==
PASS  ALL @30 fps [-]: ticks per frame measured: 2, so E1 and E2 run at both offsets
PASS  ALL @30 fps [-]: every scripted wait was met
PASS  E1 @30 fps, offset first [E1-first]: every key event was read on the tick it was sent for  (12 events; wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C: its own press read in slot b, a press read on its swing tick 1 in slot a  (read on swing ticks 0 (b), 1 (a))
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 2>3 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset first [E1-first]: swing C, the press on tick 1 ignored: on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset first [E1-first]: swing A: presses read on swing ticks [2, 10, 12, 16], the swing's own on 0  (read on swing ticks 0 (a), 2 (a), 10 (a), 12 (a), 16 (a), 18 (a))
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
PASS  E1 @30 fps, offset second [E1-second]: every key event was read on the tick it was sent for  (10 events; wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (method limit, measured): J sent for slot a of tick 0 and a slot-b J for tick 1 merge into one press, read on tick 1, which starts the swing  (tick 0: in [] sword_idle; tick 1 (slot b): in [J+J-] slash pos 0.0000, sounds 5>6)
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden  (wrong: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): hitbox live on swing ticks 2-10 only  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): one slash sound, on tick 0; no new swing on ticks 1-17  (sounds 5>6 on tick 0, J read on tick 0: true; a sound on: [])
PASS  E1 @30 fps, offset second [E1-second]: swing M (one swing from tick 1): on swing tick 17 the swing is over and sword_idle shows, the Sprite back  (tick 17: sword_idle, CHAR-SWORD-IDLE, clock -1.0000, spr 1 rig 0)
PASS  E1 @30 fps, offset second [E1-second]: swing A: presses read on swing ticks [3, 11, 17], the swing's own on 0  (read on swing ticks 0 (a), 3 (b), 11 (b), 17 (b), 19 (b))
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
== ANOMALIES ==
ANOMALY (measured, kept) E1 @30 fps, offset second [E1-second], swing M: a J press on swing tick 1 in slot b cannot follow the swing's own J in slot a of the same frame; the two merge into one press read on tick 1. Error in the test's method, not the game: tick 1 is reached in the first offset (swing C)
RESULT PASS: 66 checks, 0 failed, 642 ticks, 30 fps
```

**Run 1:** `RESULT PASS: 66 checks, 0 failed, 642 ticks, 30 fps`. `diff` of the two full outputs again differed only in the exit leak warning (`24` vs `27 ObjectDB instances`).

The count stays 66 because every E1 press at 30 fps already falls under the existing swing checks. Only the "presses read on" lists and the key-event counts changed: 11 → 12 events for the first offset, 9 → 10 for the second.

## Earlier tests

- **`scripts/run-test.sh test_rudy_pin.tscn 60`:** `RESULT FAIL: 19 checks, 3 failed, 953 ticks`, exit 1. So it's still 16 of 19, with the same three failures (`logs/test_rudy_pin_60fps.log:959-979`):
  - `FAIL  T1 run from a standstill … cells [8, 8, 7, 8, 7, 8, 7, 7]`
  - `FAIL  T2 …`
  - `FAIL  T6 the run resumes after a slash  (restarts: …)`

  The only change in its log is the leak count, 16 → 18.
- **`scripts/run-test.sh checks.tscn 60`:** 141 PASS. Its last lines:
  ```
  PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )
  all checks passed
  WARNING: 29 ObjectDB instances were leaked at exit (run with `--verbose` for details).
  ERROR: 8 resources still in use at exit (run with --verbose for details).
  ```
  The res:// count is still 98. Its log differs from the committed one in two places: the random camera-shake offset (a PASS either way) and the leak count.

## ANOMALIES

**No new check failed.** The only entry is the one kept from session 10: swing M at the second offset, a limit of the test's input method. It still means **swing tick 1 can't be reached in slot b**; it is reached in slot a, in swing C of the first offset. Ticks 3 and 12 had no such problem.
- **Tick 12 in slot a:** an ordinary frame-boundary press.
- **Tick 3 in slot b:** its frame (ticks 2 and 3) holds no other J press, so nothing merges with it.

## Every E1 press and E3 hit

Boundaries: startup → active at tick 2, active → recovery at 11, end at 17. In the table, "own" is the press that starts a swing.

| Edge | Rate, offset | Swing | Tick read (slot) | Phase |
|---|---|---|---|---|
| E1 | 60 | A | 0 own | startup |
| E1 | 60 | A | 1 | startup |
| E1 | 60 | A | **3 (new)** | active |
| E1 | 60 | A | 10 | active |
| E1 | 60 | A | **12 (new)** | recovery |
| E1 | 60 | A | 16 | recovery |
| E1 | 60 | A | 18 → starts B | after the swing |
| E1 | 60 | B | 2 | active (first live tick) |
| E1 | 60 | B | 11 | recovery (first dead tick) |
| E1 | 60 | B | 17 | end (the swing ends on this tick) |
| E1 | 30, first | A | 0 own (a) | startup |
| E1 | 30, first | A | 2 (a) | active |
| E1 | 30, first | A | 10 (a) | active |
| E1 | 30, first | A | **12 (a) (new)** | recovery |
| E1 | 30, first | A | 16 (a) | recovery |
| E1 | 30, first | A | 18 (a) → starts B | after the swing |
| E1 | 30, first | C | 0 own (b), then 1 (a) | startup |
| E1 | 30, second | M | the own press and a tick-1 press merge into one, read on 1 (b) | — (method limit) |
| E1 | 30, second | A | 0 own (a) | startup |
| E1 | 30, second | A | **3 (b) (new)** | active |
| E1 | 30, second | A | 11 (b) | recovery |
| E1 | 30, second | A | 17 (b) | end |
| E1 | 30, second | A | 19 (b) → starts B | after the swing (18 is always a slot-a tick) |
| E3 | 60 | k1 | hit on 1 | startup |
| E3 | 60 | k2 | hit on 2 | active |
| E3 | 60 | **k3 (new)** | hit on 3 | active (live on 2 only; 1 burst) |
| E3 | 60 | k6 | hit on 6 | active |
| E3 | 60 | k10 | hit on 10 | active |
| E3 | 60 | k11 | hit on 11 | recovery |
| E3 | 60 | **k12 (new)** | hit on 12 | recovery |
| E3 | 60 | k16 | hit on 16 | recovery |

So at 30 fps the two offsets together cover all nine ticks: 1, 2, 10, 12, 16 and 18 in the first; 3, 11 and 17 in the second. The only gap is tick 1 in slot b.

## `git status`

```
On branch shuai-z/assignment-7
You are in a sparse checkout with 53% of the tracked files present.

Changes not staged for commit:
	modified:   CLAUDE.md
	modified:   game/tests/test_rudy_edges.gd
	modified:   logs/checks_60fps.log
	modified:   logs/test_rudy_edges_30fps.log
	modified:   logs/test_rudy_edges_60fps.log
	modified:   logs/test_rudy_pin_60fps.log

Untracked files:
	sessions/prompt-13.txt
	sessions/prompt-14.txt
```

## What still needs a human to play

- **Re-pressing J right after each boundary** (ticks 3 and 12, as on 1, 10 and 16). Does a re-press feel ignored rather than lost, and does tick 18, the first press that counts, feel fair?
- **The new hits on screen:**
  - On tick 3 the blade has only just started its sweep. Does the cut into `hurt` read, and does the one spark burst from tick 2 look right?
  - On tick 12 the blade is just past +45°. Does the cut from the settling blade to `hurt` read?
- **What each 30 fps frame shows.** This test checks ticks, not rendered frames. For example, a press read on tick 3 in slot b falls inside frame F+1, which shows tick 3.
- **Real keys** (key repeat, very fast taps), which `parse_input_event` doesn't produce.
- **Step 5m's mutations**, run in a worktree; none has been run yet.
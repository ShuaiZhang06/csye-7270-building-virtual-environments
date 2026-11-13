# Seek-order probe: how a new swing restarts the slash clip

Claude Code wrote and ran this probe on 2026-11-12, while reviewing step 2b. It checks anomaly A1 in `sessions/session-5-answer.md`. The session found that calling `play("slash")` and then `seek(0.0, true)` made its slash end one tick early. It explained why, but could not run a probe outside the wrapper to test the explanation.

**What it does.** `seek_order.gd` builds a throwaway `Look` with a `Sprite2D` sliced 4 × 4 from the sheet and an `AnimationPlayer` on the physics callback. It loads `rudy_animations.tres` and plays `sword_idle`. Then it starts the `slash` stand-in (17/60 s, `LOOP_NONE`) in each of three ways, and records the cell and the player's state for 19 ticks.

```bash
godot --headless --path game --fixed-fps 60 --script $PWD/evidence/seek-order-probe/seek_order.gd
```

**Result** (`seek_order_60fps.log`), on Godot 4.7.2:

| Calls on the swing's first tick | The player stops on |
|---|---|
| `play("slash")`, then `seek(0.0, true)` | tick 16: one tick early |
| `seek(0.0, true)`, then `play("slash")` | tick 17 |
| `play("slash")` alone | tick 17 |

The swing ends on tick 17 (brief, section 1). With the first order, the player had already stopped on tick 17 when `rudy.gd` asked for the next clip. So the next clip's first key came a tick late, and the slash cell showed for one tick too many. That is the failure the session saw in T3 and I7.

So step 2b's `RudyLook.play_clip()` calls `seek(0.0, true)` before `play()`. The brief's section 3 names the two calls in the other order. This probe is the reason for the change.

The "slash cell on 19 ticks" in the log is expected: nothing asks for another clip after the stand-in stops, so the Sprite keeps cell 10.

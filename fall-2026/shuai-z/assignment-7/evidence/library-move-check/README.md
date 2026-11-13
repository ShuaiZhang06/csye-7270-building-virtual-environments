# library-move-check — the moved library, against its old copy and an editor-style save

Step 4 of the order Revision 5 set moved `rudy_animations.tres` from `game/content/rudy/` to `game/animations/` and gave every clip a `step` line (`sessions/prompt-12.txt`). These two scripts check what that did to the clips, and what saving the library from Godot would do.

**How it was made:** Claude Code (Claude Opus 5.5) wrote both scripts and ran them on 2026-11-13, in our conversation, while checking session 12. The output is `logs/library_move_check.log`, where local paths read `<scratch>/` and `assignment-7/`.

## Commands, from `assignment-7/`

```bash
git show 799fc127:./game/content/rudy/rudy_animations.tres > <scratch>/old.tres
godot --headless --path game --script "$PWD/evidence/library-move-check/resave_library.gd" -- <scratch>/resaved.tres
godot --headless --path game --script "$PWD/evidence/library-move-check/compare_libraries.gd" -- "$PWD/game/animations/rudy_animations.tres" <scratch>/resaved.tres
godot --headless --path game --script "$PWD/evidence/library-move-check/compare_libraries.gd" -- <scratch>/old.tres "$PWD/game/animations/rudy_animations.tres"
```

- `resave_library.gd` loads the library and saves it with `ResourceSaver.save()`, the call the editor's save uses, to a scratch file.
- `compare_libraries.gd` loads two libraries and compares, clip by clip:
  - `length`, `loop_mode` and `step`;
  - every track's path, type, interpolation, update mode and key count;
  - every key's time, value and transition, with `==`.

  The scripts sit outside `game/`, so the game gains no file.

## What they showed

- **Against the library at `799fc127`:** the 13 `step` values differ and nothing else does. Every one of the 60 keys is equal, and so is every length and loop mode. A text `diff` of the two files agrees: it shows only the 13 added `step` lines.
- **Against the resave:** no clip, track or key differs. The text does differ, on 176 lines, because the save:
  - writes the clips in alphabetical order;
  - writes `step` as `0.016666668`, the 32-bit value it holds.

  So saving the library from the editor would rewrite its layout, but no key, length, loop mode or step.
- **`step` as loaded:** 0.01666666753590107 for 1/60 and 0.125 for 1/8. A 32-bit float holds 0.125 exactly.

What this does not show: how the editor's Animation panel displays the snap. That needs the editor open, which no headless run does.

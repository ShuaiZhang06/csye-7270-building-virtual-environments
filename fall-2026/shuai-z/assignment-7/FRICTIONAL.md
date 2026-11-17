# FRICTIONAL — Assignment 7, walker-rudy

What I tried, what I expected, what happened, how I checked it, what I did about it, and what I learned, with my work and Claude's kept apart.

**How this file is written.** Claude Code drafted every entry on 2026-11-16 from our Claude Code conversations, the commit messages and the files they cite, and I check it against what I actually did. Where I recorded no expectation or lesson, the entry says so instead of inventing one. My own words are quoted in Chinese as I wrote them, each followed by Claude's English translation, marked as Claude's. Each entry says when it was written: every entry was written after the event, and those before 2026-11-16 are labelled retrospective. A session's turns, cost and denied commands come from its `claude -p` result event. The tuning rounds are in [TUNING.md](TUNING.md) and the checks in [TEST-REPORT.md](TEST-REPORT.md); this file points to them rather than repeating them.

**Tools.** Claude Opus 5.5 (`claude-opus-5-5`) in Claude Code 2.1.319 (desktop app), and the `claude -p` sessions it ran for me; Godot 4.7.2, GL Compatibility; Python 3 with Pillow, NumPy, SciPy and scikit-image; FFmpeg and ffprobe; macOS 15.1 on an Apple M3.

---

## 2026-11-10 — Reading the revision note

*Retrospective, written on 2026-11-16, from the conversation. No commit.*

- **Attempt (me):** I pasted the Assignment 7 text from Canvas and asked Claude: "告诉我作业7一步步要做什么" (Claude's translation: "tell me step by step what Assignment 7 asks me to do").
- **What Claude found:** the page was a revision note on another text, which Claude took to be the course repository's `assignments/08-animation-and-state.md`. It named three gaps:
  - the course sprite set's path was a placeholder (`<path to course sprites>`), and no such set exists upstream;
  - the "first review" the note refers to was not included;
  - there was no due date.
- **The game as it stood (Claude):** walker-rudy at `a6` had no `AnimationPlayer` at all. Rudy's poses were whole PNGs, swapped by the priority selector in `rudy.gd`.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude read the texts and explained the steps; I asked.

## 2026-11-11 — Setup: the folder, the wrapper and the baselines

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `476621f6` and `db2f8989`.*

- **Attempt (Claude, at my request: "搭分支和文件夹"; Claude's translation: "set up the branch and the folder"):**
  - Branched `shuai-z/assignment-7` from tag `a6`.
  - Copied `../assignment-6/game` into `game/` with `git archive`: 168 files, identical to their source after a headless import (`diff -rq`, `.godot/` excluded).
  - Wrote the folder's `.gitignore`: the `.godot` cache out, the six sound effects in.
- **The wrapper (Claude):** before adding patterns, Claude probed what Godot 4.7.2 prints when a resource fails to load (`evidence/load-error-probe/`).
  - A scene with a missing texture loaded, instanced and exited 0.
  - Assignment 6's wrapper caught one of the four broken probes. The new one, with seven load-error patterns added, catches all four, and the clean probe still exits 0.
  - A track to a missing property prints nothing, so only a read-back test can catch it.
- **Baselines (Claude):** `checks.tscn` 141 PASS; the tint test 15 at 30, 60 and 144 fps; the four Assignment 6 particle tests 108, 14, 61 and 14 checks; 0 FAIL in each.
- **Three slips by Claude, caught before the commits:**
  - Its first baseline loop ran in zsh, which does not split an unquoted variable. The wrapper got one argument, printed its usage and exited 2, so no test ran. Claude reran the loop in bash.
  - It counted 109 and 62 PASS lines in the config tests, against the 108 and 61 it remembered. Assignment 6's logs showed the extra line is each test's summary.
  - Its draft message said the old wrapper caught one of "five" broken probes. The fifth is the clean control, so it became four before the commit.
- **My decision:** `CLAUDE.md` starts empty: "照 A6 留空" (Claude's translation: "leave it empty, as in A6"). Assignment 6's file is about particles and imports that brief.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude did the copy, the probe, the wrapper and the baselines. I decided the empty file and approved both commits ("提交", "commit").

## 2026-11-12 — Choosing the two clips

*Retrospective, written on 2026-11-16, from the conversation. No commit; the choices are in `CHANGE-BRIEF.md`, Revision 1.*

- **Attempt (me):** I asked Claude to settle the two clips: "定两个片段" (Claude's translation: "decide the two clips"). Claude read Rudy's art, the Assignment 2 sources and the slash code, and put three questions to me, each with options and a recommendation.
- **My choices,** each the option Claude recommended:
  - **The clips:** Rudy's run as the looping sprite clip, and the sword slash as the committing action on a cutout rig. The two other options used a goblin.
  - **The sprite source:** Rudy's own Assignment 2 frames, rather than waiting for the course sprite set or using a licensed sheet.
  - **The slash's startup:** kept at 2 ticks (0.03 s). Lengthening it would change gameplay and need its own pin and re-pin.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude proposed the options and their costs; I chose.

## 2026-11-12 — The brief, its base text and the motion reference

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `d83e47db` (probes and reference) and `296c6bdf` (the brief, Revision 1, alone).*

- **The draft (Claude, at my request: "起草 brief"; "draft the brief"):**
  - Claude first ran headless probes in a scratch copy, so that every timing in the brief cites a log (`evidence/brief-probe/`). Among them: the slash is on screen for 17 ticks, with its hitbox live on ticks 2–10; `play()` on a stopped player is a tick late; a continuous frame track shows RUN-B 4 ticks early; Godot 4.7.2 maps `loop = true` but drops `playback_speed`.
  - It wrote a 434-line draft and checked every `file:line` it cites with a script.
  - It left section 8, the motion reference, empty: it said the assignment wanted frame counts that I had measured, and asked me to film a swing and a run.
- **My objection:** "作业具体哪里要求了需要是我量出来的帧数？然后我要跟你强调一点，每次作业优先只看那次作业的要求，不是一定要参考之前的作业的。" (Claude's translation: "Where exactly does the assignment require frame counts that I measured? And I want to stress one point: for each assignment, look first only at that assignment's requirements; it need not follow the earlier assignments.")
  - Claude found that the text I had pasted does not say it. The phrase "the frame counts you measured" is in the repository's `08` file (line 44), which Claude had taken as the main text without saying so.
  - It listed what in the draft came from Assignments 5 and 6 rather than from either text.
- **My decision on the base text:** "只有贴的这段，但我觉得是教授给错了，我觉得主要看GitHub仓库里的正文" (Claude's translation: "There is only the part I pasted, but I think the professor posted the wrong thing; I think the main text in the GitHub repository is what counts").
  - So Revision 1 works to the `08` file with the note on top, and its opening says so.
  - Claude removed the rules carried over from Assignments 5 and 6: the absolute-path session rules, the shaders check line, and "never a scoped session" for captures.
  - Claude later found an earlier draft of the note in the course's `walker-claude` repository that supports this reading (Revision 1's opening).
- **The motion reference:**
  - I chose public footage over filming myself: "找公开素材" (Claude's translation: "find public footage").
  - Claude found three openly licensed Wikimedia Commons videos, and named each file, its source, licence and size (about 11.3 MB in all) before downloading. I said yes: "可以下载" ("you may download them").
  - Claude counted the frames on contact sheets it made. Its predictions, written before the counts, were off, and stay in the brief with the misses marked (section 8): a wind-up of 6–10 frames against 15 measured; a strike of 2–4 against 6; a jog of 9–10 frames per step against 11.
  - It corrected its own citation of the run study, 2014 to 2015, before the commit.
- **My check:** I checked Claude's counts against the contact sheets and said to commit: "核对好了，提交" (Claude's translation: "checked; commit"). The videos and frames are not committed. `evidence/motion-reference/README.md` holds the sources, licences, SHA-256 and counts.
- **Expected / learned:** none recorded.
- **Human / AI:** Claude ran the probes, drafted the whole brief, and found and counted the footage. I chose the clips, the base text and the footage, corrected Claude on what the text requires, checked the counts and approved the commits.

## 2026-11-12 — CLAUDE.md, a README, and the plan session

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `251ddc24`, `9194c98b` and `2e79a9bf`; prompt `sessions/prompt-1.txt`; answer `sessions/session-1-answer.md`; my decision `sessions/plan-1-review.md`.*

- **Whether to write CLAUDE.md.** After the brief, Claude said `CLAUDE.md` had to be written before the first prompt. Revision 1 said every prompt the assignment supplies begins "Read CLAUDE.md first".
  - I pointed at the GitHub text: "github原文并没有说一定要写claude.md吧" (Claude's translation: "the GitHub original doesn't say CLAUDE.md must be written, does it?"). Claude checked: the `08` file never names it, so Revision 1's sentence was wrong.
  - I first chose a revision and an empty file: "好，加第2版修订，CLAUDE.md留空" ("OK, add Revision 2, and leave CLAUDE.md empty").
  - Then I noticed that the note's draft prompts do use it: "等一下，我之前没注意到canvas中的修订有提到claude.md，你觉得我要不要写claude.md？" (Claude's translation: "Wait, I hadn't noticed that the Canvas revision mentions CLAUDE.md. Do you think I should write CLAUDE.md?"). Claude recommended a short file of stable facts only, and said what it would cost.
  - **My decision:** "好，写一个简短的CLAUDE.md，改写第2版修订" ("OK, write a short CLAUDE.md, and rewrite Revision 2"). Claude wrote 42 lines that point to the brief and repeat none of its design. They went in with Revision 2 (`251ddc24`).
- **A README first.** The plan prompt reads `README.md`, which this folder lacked. I chose to write a short one first: "先写简短 README" ("write a short README first"). Checking its draft against `rudy.gd`, `goblin.gd`, `main.gd` and the level, Claude corrected three of its own statements: a stomp is not a hurt; the defeat pose shows only after a hit takes the last heart; and where he respawns.
- **The plan session (Claude's prompt; a read-only `claude -p` run):**
  - The `08` file's plan prompt with three changes, listed in `plan-1-review.md`.
  - Result: success, 34 turns, about 206 s, USD 1.72. One compound Bash call was denied, so it ran no Godot command, and nothing changed.
  - Claude spot-checked eight of its line references, all right. The session found that `checks.gd:732` accepts a swing within ±2 ticks, so it cannot tell 17 ticks from 19.
- **My decision:** "接受并修正" (Claude's translation: "accept it, and correct it"), with the four corrections Claude proposed:
  - T1 and T2 fail too, not only T6;
  - clips are made first, then wired (2a/2b, 4a/4b);
  - mutation checks in a worktree;
  - for the pin, the test's own scene rather than `main.tscn`, my choice of Claude's two options.
- **Expected / learned:** none recorded.
- **Human / AI:** I questioned the CLAUDE.md claim and made the three decisions. Claude drafted `CLAUDE.md`, Revision 2, the README, the plan prompt and the record, ran the session and checked it.

## 2026-11-12 — Step 0: the pin

*Retrospective, written on 2026-11-16, from the conversation and the commit. Commit `3908ae80`; prompts `sessions/prompt-2.txt` and `prompt-2b.txt`; answers `sessions/session-2-answer.md` and `session-2b-answer.md`.*

- **The run (session 2, Claude's prompt):** writes were allowed only to the two pin files. Success, 28 turns, USD 2.55, one compound command denied. Its pin passed 19 checks in three runs, with the values it measured: the run's cells 7, 8, 7, 8, 7, 7, 8, 7; the slash pose on ticks 0–16; the hitbox live on ticks 2–10; HURT for 21 ticks.
- **A fault from Claude's prompt:** the prompt forbade calling Rudy's or RudyLook's methods, a rule the `08` text does not have. So I5 compared the Sprite's texture, which the planned sheet would break on every tick.
- **My choice:** Claude offered to resume the session, or to edit I5 itself, which would make part of the test its own. I chose: "让它在原会话里改" (Claude's translation: "have it make the change in the original session").
- **The resume (2b):** success, 13 turns, no denial. I5 now checks `RudyLook.frame() == RudyLook.FRAMES[Rudy.pose]` on every tick. Claude had estimated between a few tens of cents and USD 1; the result event reports USD 3.13, which Claude guessed includes session 2's 2.55, without verifying it.
- **Checks (Claude):**
  - It diffed the test against a copy taken before the resume: only I5 and its comments changed.
  - It reran the pin (19 PASS) and `checks.tscn` (141 PASS). The checks log differs from the baseline only in the camera shake, the leak count and the `res://` path count (89 → 90, the new scene).
- **Expected / learned:** none recorded. Claude's own note for later prompts: allow read-only queries such as `frame()` and `is_on_floor()`.
- **Human / AI:** session 2 wrote the pin and its fix. Claude wrote both prompts and checked the result. I chose how to fix I5 and approved the commit ("提交").

## 2026-11-12 — Steps 1 and 2: the sheet, the sprite clips and the wiring

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `0736d0fa`, `ff786958` (Revision 3), `5017c412` and `400abd36`; prompts `sessions/prompt-3.txt` to `prompt-5.txt`.*

- **The sheet (session 3, USD 1.03) worked the first time.**
  - The packing script checks its inputs, rereads the saved sheet and compares each cell with its source; its `--self-test` damages copies, which must fail.
  - Claude checked it two more ways: its own NumPy cell comparison, and a Godot read-back of the imported sheet, whose 16 cells are byte-identical to the imported frames.
  - Its import also made the pin's `.uid`, which step 0's commit had left out; it went in here.
- **Revision 3 (Claude):** drafted while preparing step 2a, it states four things 2a needed that the brief left open. I approved the commit before the session ran: "好，先提交再跑" ("OK, commit first, then run").
- **The sprite clips (session 4, USD 1.60):**
  - 13 clips in one library, and a read-back test of 21 checks in all, in which a damaged in-memory copy for each check must fail.
  - Claude had predicted 92 `res://` paths; there were 93, because the test also loads the sheet.
  - Claude played every clip on a throwaway Sprite, to check the cells by tick.
- **The wiring (session 5, USD 3.29):**
  - The pin failed exactly T1, T2 and T6, the three the corrected plan predicted.
  - The session's first wiring called `play()` and then `seek(0.0, true)`, which ended the slash a tick early and failed T3 and I7. It reversed the calls. Claude's probe confirms it (`evidence/seek-order-probe/`). The brief's section 3 named the wrong order, and Revision 4 records the change.
  - The run also restarts after a hurt, a defeat and respawn, and a sword pickup mid-run. The brief's "one intended change" understated this, and no test sees these cases.
- **My look:** "我打开assignment7的游戏项目，好像没看到什么不同啊？" (Claude's translation: "I opened the assignment-7 game project, and I don't seem to see anything different?").
  - Claude explained that 2b changes what draws Rudy, not the picture: the same 16 frames, the first run cell a tick longer, the run restarting after a slash.
  - It suggested `--time-scale 0.25`, and the editor's remote tree, to see the player at work. I did not report doing either, and asked to commit: "先提交 2b" ("commit 2b first").
- **Expected / learned:** none recorded, beyond my question above.
- **Human / AI:** sessions 3–5 wrote the script, the clips, the tests and the wiring. Claude wrote the prompts and Revision 3, checked each step and wrote the seek-order probe. I approved each step and each commit.

## 2026-11-12 — Step 3: cutting the rig, from a prompt that contradicted itself

*Retrospective, written on 2026-11-16, from the conversation and the commit. Commit `de54303b`; prompts `sessions/prompt-6.txt` and `prompt-6b.txt`; previews in `evidence/rig-cut/`.*

- **Claude's prompt:** after looking at `CHAR-SWORD-SLASH.png`, Claude put the pommel, which shows below the fist over the sleeve, in the blade part. The same prompt kept the sword drawn behind the body. Both cannot hold: the cut leaves a notch in the sleeve whenever the blade turns.
- **The run (session 6):** success, 128 turns, about 26 minutes, USD 7.74.
  - It reported the conflict instead of working around it.
  - It also left 30 dark pixels in the arc near the shield, and faint traces on the robe and shield where the arc was removed.
  - It made no import log: it tried a redirect and a direct write, not the `tee` it was allowed.
- **The correction:** Claude said the pommel was its prompt's fault and drafted `prompt-6b.txt`: the pommel and grip back in the body, unrepaired, as section 2.2 words it; the arc's colours kept within its own range; the import log by `tee`. I approved it: "好，续跑修正" (Claude's translation: "OK, resume it and correct it").
- **The cost:** the resume, 85 turns, cost USD 11.75 on its own, more than the first run, because it carried the first run's long context. Step 3 cost about USD 19.5. Claude said that to correct a long session it would rather start a new one with a short hand-off.
- **Checks (Claude):** its own composite of the parts differs from the frame in 308 pixels, all inside the repaired band. No pixel is in both blade and body, no dark arc pixel is left, and the source frame's SHA-256 is unchanged.
- **What I accepted,** by approving the resume and the commit: the sword now kinks at the fist by the Grip angle, and the band's traces were left to be judged on the strip after step 4b (brief section 10, row 12).
- **Expected / learned:** none recorded.
- **Human / AI:** session 6 wrote the cutting script, the parts and the previews. Claude wrote both prompts, the contradiction included, and checked the parts. I approved the correction and the commit.

## 2026-11-12 — Step 4: the rig clip, the wiring, and my look at the slash

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `e7f2eecb` (Revision 4), `63dc973b` and `3a9ec819`; prompts `sessions/prompt-7.txt` and `prompt-8.txt`.*

- **Revision 4 (Claude):** what steps 2b and 3 found, and how step 4a is staged so that nothing plays the rig yet. I approved the commit before the session.
- **The rig clip (session 7, USD 2.93):**
  - The `SlashRig` nodes, hidden, and the keyed clip under a new name.
  - A read-back of 44 checks, including a `get_indexed()` check, since `track_problems()` reads only a path's first subname.
  - The session found that these keys make the blade nearly stop at its drawn angle: 33° on tick 5, then 1.2° on tick 6 (`sessions/session-7-answer.md:191`). Claude recomputed it, and it was left for the strip.
- **The wiring (session 8, USD 2.50):**
  - The rig clip took the stand-in's name, and the pose reads `CHAR-SWORD-SLASH` while the rig shows.
  - The pin's log was byte-identical, so no headless test saw the change.
  - Claude's probe of the running game, in a scratch copy (`evidence/rig-wire-probe/`): the rig shows on ticks 0–16, the hitbox opens on tick 2 at the −60° key, and the stall is there, 1.25° on tick 6.
- **My look:** before the commit I looked at the slash in the running game: "看过了 没问题 提交" (Claude's translation: "looked at it; no problem; commit"). My words do not say at which speed. Claude's reply after the commit said I had seen no problem at normal speed; I had not said so.
- **Expected / learned:** none recorded.
- **Human / AI:** sessions 7 and 8 made the rig and its wiring. Claude wrote Revision 4 and the prompts, recomputed the stall and wrote the probe. I looked at the slash and approved the commits.

## 2026-11-12 and 2026-11-13 — Step 5: the state test and the edge test

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `beb514cd` and `ea9e75a8`; prompts `sessions/prompt-9.txt` and `prompt-10.txt`.*

- **The split:** Claude proposed splitting step 5 into a state test and an edge test, since one session doing both would be long and costly. I agreed: "好，开跑 5a" ("OK, run 5a"). The commit body says "I split" it; the proposal was Claude's.
- **The state test (session 9, USD 4.39):**
  - It runs the real `Main`, driven only by key events after setup: 81 PASS, the same in three runs.
  - It saw 39 of the brief's 57 transitions and listed the 18 it did not reach.
  - One finding is off the brief's table: walking into the pickup mid-run turns `run` into `sword_run`.
  - Claude checked that the test writes Rudy's position only in setup.
- **The edge test (session 10, USD 5.07),** run late on 2026-11-12: 98 PASS at 60 fps and 66 at 30, at both tick offsets. No edge failed.
  - **A limit of the method:** at 30 fps, a re-press on swing tick 1 in a frame's second tick merges with the swing's own press. Tick 1 is tested in the other offset.
  - **Two findings against the brief:** section 10, row 4 claims that E1's tick-18 check catches a slash that is not restarted, and it cannot; and on the baseline commit the edge test cannot run at all, since there is no rig there.
- **Committed the next day,** after the full Canvas text arrived (next entry), as Claude proposed: it was finished before that text, and the text asks for commits in the order the work happened.
- **Expected / learned:** none recorded.
- **Human / AI:** sessions 9 and 10 wrote the tests. Claude proposed the split, wrote the prompts and checked both. I approved them.

## 2026-11-13 — The full Canvas text, and who writes the brief

*Retrospective, written on 2026-11-16, from the conversation and the commit. Commit `15be6100` (Revision 5).*

- **Attempt (me):** I paused the work and pasted the full Assignment 7 text that Canvas now showed: "先暂停一下。以下是canvas上最新的作业要求，果然和我之前想的一样，之前canvas上的要求是错的，本次作业都以下面最新的作业要求为准。你看下目前做的内容，哪里需要修改吗，还是就继续做下去？" (Claude's translation: "Pause for a moment. Below is the latest assignment text on Canvas. It is as I thought: the earlier requirements on Canvas were wrong. For this assignment, the latest text below is what holds. Look at what we have done: does anything need changing, or do we just carry on?")
- **Claude's comparison:** most of the work stands, including the brief and the pin, both committed before any change. Nine things change or are added:
  - `CLAUDE.md` rewritten by the text's Step 1 and importing the brief, the reverse of Revision 2;
  - the library moved to `game/animations/`;
  - `Animation.step` set and pinned;
  - the text's four mutations;
  - edges on ticks 3 and 12;
  - a brief revision;
  - credits files next to the sheet and the rig;
  - every transition reached or explained;
  - the pin's order of states.

  It proposed an order of eight items, and I approved it: "好，按这个顺序" ("OK, in this order").
- **Who writes the brief.** The text says the student writes the brief, the phase table, the cycle spec, every prediction and every verdict. Claude offered two ways, and recommended the first: I would say it and Claude would write it up in English; or Claude would draft and I would review, as before, recorded as a departure from the text.
  - **My choice, against Claude's recommendation:** "照旧你起草我审" (Claude's translation: "as before: you draft, I review").
  - So every brief revision and prediction in this assignment is Claude's draft that I approved, and Revision 5 says so. Verdicts and human checks stay mine, and record only what I saw.
- **Revision 5 (Claude):** the new base text; what each clip tells the player; `step` (1/60 s for the slash, 1/8 s for the run); the library's move; the frame-strip spec; the edges; the four mutations, with the prediction that the empty-cache one passes; the corrected transition table; the pin's order; and answers to the text's seven questions. I approved the commit ("好，提交").
- **Expected / learned:** on 2026-11-12 I had thought the first Canvas page was posted wrong, and the full text confirmed it ("果然和我之前想的一样"; Claude's translation: "it is as I thought").
- **Human / AI:** I brought the new text, approved the order and chose who writes the brief. Claude compared the texts and drafted Revision 5.

## 2026-11-13 — Step 1 of the text: the CLAUDE.md draft and my review

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `5b6d8ca6` (the draft, unedited) and `799fc127` (the review); prompt `sessions/prompt-11.txt`; answer `sessions/session-11-answer.md`.*

- **The prompt (Claude):** the text's Step 1 prompt with this folder's paths. It is `prompt-11`, because `prompt-1.txt` was already the plan session's.
- **The run (session 11):** `dontAsk`, with Edit and Write allowed only on `CLAUDE.md` and denied on `game/shaders/`, and `--max-turns 60`.
  - Result: success, 31 turns, 127 s, USD 1.39, one compound command denied.
  - A hash snapshot showed that only `CLAUDE.md` changed; `git diff --stat game/shaders/` and `git diff scripts/run-test.sh` printed nothing.
  - The 105-line draft was committed unedited, as the text asks.
- **The review (Claude, at my word: "好，开始复核"; "OK, start the review"):**
  - Every reference was opened; four line ranges were off and were corrected.
  - The text's four "Headless facts" were each confirmed first by a probe (`evidence/headless-facts-probe/`). One needed a qualifier: key times loaded from resource text are 32-bit, but keys inserted from code stay 64-bit until saved. Movie Maker under `--headless` crashed with signal 11; in a window it wrote 10 frames.
  - The draft's extra Git section was folded into Ownership, so the sections follow the text's order: 108 lines.
  - One reading of the rules was put to me: a test may damage an in-memory copy of a clip for a NEGATIVE check, but never saves or plays it. I approved it with the review's commit: "好，提交复核" ("OK, commit the review").
- **Expected / learned:** none recorded.
- **Human / AI:** session 11 wrote the draft. Claude wrote the prompt, ran the session, reviewed the draft and wrote the probe. I approved both commits.

## 2026-11-13 — The library's move, `Animation.step`, the edges and the transitions

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `4b4e7b92`, `01d6b55d` and `f1680bfb`; prompts `sessions/prompt-12.txt` to `prompt-14.txt`.*

- **The move (session 12, USD 2.34):** the library moved to `game/animations/` with `mv`, and every clip gained its `step` line. Claude compared the libraries: only those 13 lines differ. The read-back now passes 51.
  - **A test that failed on a path it named.** Check 12 needs the old path, to show that no file is left there. `checks.gd` requires every `res://` literal in the project to exist, so the first run failed (100 paths, one missing). The session derived the old path at run time instead.
  - Claude put that to me, with the other choice of dropping that half of the check. I accepted it by approving the commit ("好，提交").
  - Claude also checked that an editor resave (`ResourceSaver.save()`) changes no clip or key (`evidence/library-move-check/`).
- **The edges (session 13, USD 2.04):** E1 and E3 gained swing ticks 3 and 12, so every phase boundary has an input before, on and after it: 108 PASS at 60, 66 at 30. It matched the prediction the first time, and Claude's reruns gave the same logs.
- **The transitions (session 14, USD 3.95):**
  - The table corrected to Revision 5's 58 transitions, and scenarios S9–S20 added: 54 reached, 4 listed with reasons.
  - It corrected session 9, which had judged `sword_idle → celebrate` reachable.
  - Two line citations in its reason text were wrong, and Claude fixed them (`goblin.tscn:8`, `spikes.tscn:8`).
- **My decisions:** to run 13 and 14 one after the other: "好，先跑 13" ("OK, run 13 first"), then "好，提交并跑 14" ("OK, commit it and run 14").
- **Expected / learned:** none recorded.
- **Human / AI:** sessions 12–14 made the changes. Claude wrote the prompts, checked each and fixed the citations. I chose the order and accepted the old-path workaround.

## 2026-11-13 — Step 6: the pin's order of states and the four mutations

*Retrospective, written on 2026-11-16, from the conversation and the commits. Commits `3b0dea9e` and `6eab8f49`; prompt `sessions/prompt-15.txt`; evidence `evidence/mutations/`.*

- **I9 (session 15, USD 1.41):** a new pin line compares the order of the 33 states in the scripted run with the baseline log committed with the pin. It was added after the change, and the test says so.
  - At the head: 20 checks, with only T1, T2 and T6 failing.
  - Claude ran it on `3908ae80` in a throwaway worktree: 20 PASS, so it held before the change.
- **A check that did not run.** Claude's first count of files naming `AnimationPlayer` at `3908ae80` came from a `grep` that a zsh glob had stopped from running, so its 0 meant nothing. Claude reran it as `git grep`: 0 files there, and 6 at the head as a control. `logs/pin_I9_on_3908ae80.txt:4` records this.
- **The mutations (Claude, in our conversation):** each in a fresh worktree of `f1680bfb`, removed afterwards.
  - M1 (a broken subname), M2 (`LOOP_NONE` on the run) and M3 (a frame key of 16) each exit 1.
  - M4 (empty cache, then reimport) passes, as Revision 5 predicted: the rig is keyed as resource text, so the cache holds no clip.
  - All five runs, the control included, came out as predicted.
  - Before the commit, Claude replaced the local paths written into `mutate.sh`.
- **My decision:** two commits: "好，分两次提交" ("OK, commit it in two").
- **Expected / learned:** none recorded.
- **Human / AI:** session 15 wrote I9. Claude ran the baseline worktree and the mutations and wrote the records. I approved them.

## 2026-11-16 — Playing the run, and the re-pin

*Written on 2026-11-16, from the conversation and the commit. Commit `e45658e6`; prompt `sessions/prompt-16.txt`.*

- **Attempt (me):** Claude had asked me to play the run at normal speed and at 0.25, and to watch five cases. I said: "我看过了 没问题" (Claude's translation: "I have looked at it; no problem"). The record claims no more than that: not which speeds, not which cases.
- **Before the prompt (Claude):** a tick-by-tick comparison of the pin's trail at `3908ae80` and now. Only the pose differs, and only between a run's two cells: one-tick shifts, the sword pickup mid-run (ticks 284–288), and the run after a slash (ticks 687–732). So no pin changed for a reason the brief did not predict.
- **The re-pin (session 16, USD 1.36):** T1, T2 and T6 take the new values, with the baseline values kept in comments; nothing else in the test changed.
  - It worked the first time: 20 PASS twice, and the 953-tick trail is byte-identical to the one before.
  - It is its own commit, with the reason, as the text asks.
- **A loose sentence in the brief:** the session noticed that section 7 says the cells "last 7 and 8 ticks in turn", while the measured order is 8, 8, 7, 8, …, as the probe the section cites shows. Revision 6 corrects the wording.
- **Expected / learned:** none recorded.
- **Human / AI:** I played the run. Session 16 changed the three values. Claude compared the trails, wrote the prompt and checked the result.

## 2026-11-16 — Step 7: the previews, and two mistakes in Claude's set-up

*Written on 2026-11-16, from the conversation and the commit. Commit `13707a13`; prompts `sessions/prompt-17.txt` and `prompt-17b.txt`.*

- **Session 17 (USD 1.82)** wrote both preview scenes, but every headless run it tried was denied. **Claude's mistake:** the allow rules it wrote for the session ended mid-word (`res://previews/:*`, `tee logs/:*`). Such prefix rules match only at a word boundary, so they matched nothing.
- **A frame late (Claude's mistake):** Claude ran the session's commands itself. Every value matched Revision 5's table, but one frame late. Claude's prompt had assumed two ticks in every frame. At `--fixed-fps 30`, frame 0 runs one tick and frame N ≥ 1 runs ticks 2N−1 and 2N, so J was read in frame 31.
- **The resume (17b, USD 4.04, no denials),** on my word: "好，续跑" ("OK, resume it").
  - Presses are now sent at the end of frame 29; keys are released by ticks, so that a run at `--time-scale 0.25` still reads them; and the log prints where each press was read.
  - Claude reran all four previews: slash frames 29–38 match Revision 5's table.
  - Session 17 was short (17 turns), so Claude resumed it rather than start a new one. The resume still cost more than twice the first run.
- **A wrong header line:** the session reported its own derived run table wrong at frame 37, where RUN-B still shows. I said: "好，你来改" (Claude's translation: "OK, you make the change"). Claude changed those two header lines in `run_preview.gd` and reran both run previews: only the header lines changed.
- **Expected / learned:** none recorded.
- **Human / AI:** session 17 wrote the previews. Claude wrote both prompts, both mistakes included, ran the checks and fixed the header on my word. I approved the resume, the fix and the commit.

## 2026-11-16 — Strip r0 and my first verdict

*Written on 2026-11-16, from the conversation and the commit. Commit `c70c8367`; the record is `TUNING.md`, "r0".*

- **Who ran the captures.** I asked: "你来截图，我来写第一印象，你如实记录就行（我具体需要写哪些？）" (Claude's translation: "You take the captures, I'll write my first impression, and you just record it faithfully. (What exactly do I need to write?)").
  - Claude quoted the text: I run every capture ("You run the capture, not the agent"). It listed what to look at, at normal speed and at 0.25: each phase, any catch in the sweep, the arc, the kink at the fist, the band on the robe, and the run's cells and feet.
  - **My choice, against the text:** "还是你来跑" (Claude's translation: "you run them after all"). So strip r0 does not follow the text, and `TUNING.md`, Revision 6 and `CLAUDE.md:59` say so.
- **The captures (Claude):** four windowed Movie Maker runs of the previews. Their logs match the headless ones line for line; in the window too, frame 0 runs one tick. Only the 39 frames to read were kept.
- **My first verdict,** before Claude read any frame: "起手、出招、收招，三段分得开；剑扫过去没有卡一下；其余的肉眼没看出明显问题" (Claude's translation: "Startup, active and recovery: the three phases are distinct. The sword does not catch as it sweeps across. Beyond that, I saw no obvious problem with my eyes"). It does not say which previews I watched, or at which speed, and it does not name the arc, the kink, the band or the run.
- **Expected / learned:** none recorded.
- **Human / AI:** the verdict is mine. Claude ran the captures at my request, checked the logs, kept the frames and recorded my words.

## 2026-11-16 — Tuning round r1: Claude's reading, the change, strip r1 and my verdict

*Written on 2026-11-16, from the conversation and the commits. Commits `c9ccab9b` and `66103310`; prompts `sessions/prompt-18.txt`, `prompt-18b.txt` and `prompt-18c.txt`; the round is `TUNING.md`, "r1"; our disagreement is `TEST-REPORT.md`, "Claude against you".*

- **Claude's reading of r0 (session 18, read-only, USD 1.48), a claim:**
  - The phases follow the table. But the blade nearly stops at tick 5, because both Grip keys around it ease in, and it is horizontal only at tick 9.97, against the reference's tick 8. That contradicts my "no catch".
  - It found that Revision 5's "the stall of Revision 4" cites nothing in Revision 4: Claude's drafting slip.
  - It proposed one change: the Grip key at 5/60 eases out instead of in. Claude recomputed every predicted value with Godot's ease formula.
- **My decision:** "批准，续跑去改" (Claude's translation: "approved; resume it and make the change"). The resume (18b, USD 2.48) changed the key, the read-back's expected value and two preview header lines. Every test kept its count, and the logs moved only where Grip is logged.
- **Not the round the text asks for:** this round was driven by Claude's reading, not by something I saw. The text's observation-driven revision is still owed; Claude said so before I approved, and `TUNING.md` and both commits say so.
- **Strip r1:** again captured by Claude at my request ("还是你来跑"). Claude's comparison (18c, read-only, USD 3.12), a claim: every logged value matches the prediction, and the stop is gone. Its caveats: a near-hold of about 100 ms in the second capture, and the hitbox closing while the blade rests.
- **A command of mine that failed:** I ran `godot --path game --time-scale 0.25` from the repository root, where there is no `game/`, and Godot answered `Invalid project path specified: "game", aborting.` Claude explained, and gave me the command with the project's full path; the game opened.
- **My verdict, in the running game:** "我用0.25倍速看的，保留这处改动，就这样了，没什么大问题" (Claude's translation: "I watched it at 0.25 speed. Keep this change. That's it; no big problem"). I watched at 0.25 only, and said nothing about the catch, the settle or the near-hold.
- **Expected / learned:** none recorded.
- **Human / AI:** I approved the change and kept it after play. Session 18 read both strips and made the change. Claude wrote the three prompts, checked the numbers, ran the capture and recorded my words.

## 2026-11-16 — Brief Revision 6 and its follow-ups

*Written on 2026-11-16, from the conversation and the commits. Commits `5865cefe` and `09ce1cb7`.*

- **Revision 6 (Claude):**
  - the kept change, and why;
  - the frame strip corrected: trigger frame 30; F+3 at +25°; the wrong "stall of Revision 4" citation replaced by `sessions/session-7-answer.md:191`; F+5 only about 14° below horizontal;
  - the second offset's table added;
  - who ran the captures;
  - section 7's run cells;
  - the four transitions not reachable on Level 1, kept in the table and marked.

  I approved the commit ("好，提交").
- **Follow-ups, on my word ("好，你来改"):** the preview's header now cites Revision 6, and `CLAUDE.md:59` says who ran r0 and r1. Reruns showed that only header lines changed.
- **A mistake in Revision 6, fixed beyond what I approved:** Revision 6 cited `logs/slash_preview_headless.log:18-19`, the line numbers of that log before `13707a13`. Claude found it while editing and corrected the line reference inside the committed revision. It told me that this went beyond my approval and could be withdrawn, and I committed it ("好，提交").
- **Expected / learned:** none recorded.
- **Human / AI:** Claude drafted Revision 6, made the follow-ups and found its own wrong reference. I approved each commit.

## 2026-11-16 — Use It: TEST-REPORT and my human checks

*Written on 2026-11-16, from the conversation and the commit. Commit `c9bb0504`; the results are in `TEST-REPORT.md`.*

- **The headless rows (Claude):** every test rerun at `09ce1cb7` through the wrapper, and each count equals its committed log. One of Claude's counting commands split its arguments wrongly in zsh again, and Claude recounted in bash.
- **The human checks** stayed "not done yet" in Claude's draft until I reported them:
  - the four checks: "我亲手做过了。循环接缝没问题。实际玩也没问题。对位正常，背景正常。" (Claude's translation: "I did them myself. The cycle seam: no problem. Actual play: no problem too. Registration is normal, the background is normal");
  - the editor run: "跑过了，没问题" (Claude's translation: "I ran it; no problem").

  Each row says what my words do not state: how many wraps, which form, which interrupts, which stretches of the level.
- **Expected / learned:** none recorded.
- **Human / AI:** the human checks and the editor run are mine. Claude ran the tests and drafted the report around my words.

## Two notes the text asks for

- **Interrupted sessions: none.** No `claude -p` run stopped at `--max-turns` or ended interrupted: all 23 result events read `success`, `is_error` false and `terminal_reason` `completed`. The resumed runs (2b, 6b, 17b, 18b, 18c) went back to finished sessions to correct them or to take the next approved step. Our own conversation moved to a new Claude Code session twice, each time pointing at the earlier one, and was summarized once when its context filled. Neither is a `claude -p` run.
- **Changed games since Assignment 2: no.** walker-rudy is my Assignment 2 game, and `game/` was copied unchanged from tag `a6` (`476621f6`).

## Open questions

- **The observation-driven revision is still owed.** The text asks for at least one revision driven by something I saw in the running game. Round r1 was driven by Claude's reading, and in play I saw no problem (`TUNING.md`, r1; `TEST-REPORT.md`, "Still open").
- **Was r1 needed?** I never saw the catch: not in the game after step 4b, and not in the r0 previews. I kept r1 after watching at 0.25 speed only, never at normal speed. Claude's caveats from strip r1, and its note that the hitbox is live on ticks 2–4 while the blade is still overhead, have not been checked by my eyes.
- **The kink and the band.** Step 3 left the kink at the fist and the band's traces for my eyes on the strip. None of my verdicts names them.
- **The transcripts.** The text asks for each `claude -p` transcript under about 1 MB, or a labelled excerpt. `.gitignore` keeps `sessions/*.jsonl` local, because they hold local paths and session IDs. Of the 23, 11 are under 1 MB and 12 are over; the largest, `session-18c.jsonl`, is about 7.3 MB. This is not decided yet.
- **Ship It is not done.** The film is not made. `SOURCES.md`, the README's update and the two `ATTRIBUTION.md` files were drafted by Claude on 2026-11-16, and were not yet committed when this file was drafted.

Claude Code drafted this file on 2026-11-16 from the commits, the conversation and the files they cite, for me to check.

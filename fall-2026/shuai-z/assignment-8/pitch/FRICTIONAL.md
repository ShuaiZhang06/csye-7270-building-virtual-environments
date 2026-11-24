# FRICTIONAL — Assignment 8, the final project pitch film

*Drafted by Claude Code (Claude Opus 5.5) from our conversation; I review every entry. Dated entries, added as the work goes.*

**Tools.** Claude Opus 5.5 in Claude Code (desktop app); Godot 4.7.2; macOS on an Apple M3; the Brutalist toolkit checked out locally.

## 2026-11-20 — Reading the assignment

- I pasted the assignment's Canvas text and my Assignment 4 GDD (PDF) and asked what to do, step by step.
- Claude could not render the PDF's pages (`pdftoppm` is not installed) and read its text with `pypdf` instead. The figures were not seen.
- Four things Claude found before any work:
  1. Brutalist's show-tell skill opens with Liam "in for Bear" and closes with a spoken @NikBearBrown outro, and my Assignment 7 film's beat sheet used the persona "Liam (in for Bear)". This assignment says AI narration "speaks as you" and must not use "the instructor's name, persona or credit line", so the bookends have to change. If the toolkit's bookend check then fails, that goes here.
  2. This assignment says to leave out private conversation transcripts. Assignment 7 committed redacted ones; that is not carried over.
  3. My GDD was submitted on Canvas only, and its branch was never pushed, so the "exists today" list cannot point a reviewer to a commit for it.
  4. The local Brutalist checkout is one commit behind its remote.
- Claude proposed three directions: A, a vertical slice of my game; B, the character controller and animation states with the GDD's block and staff; C, a shader and effects pack.

## 2026-11-22 — Choosing the project

- I chose **A, the vertical slice**.
- My answers (translated from Chinese): the comparable games I have played are *Super Mario Bros.* and *New Super Mario Bros.*; I picked the project mostly to learn; I had none of the course's skills before this semester; the reader is the professor, who wants to see our ideas for the final project and check that the scope is neither too complex nor too easy; the export target is Web.
- I did not understand what the "target role" question meant. Claude put "gameplay programmer" in the draft, to be confirmed by me.
- Claude created the branch `shuai-z/assignment-8` from tag `a7` and the `pitch/` folder, and drafted PROJECT-BRIEF.md (draft 1). Nothing is committed yet.
- While drafting, Claude changed one claim before showing it to me: "once the swing starts, it plays out" became "no new swing starts until the last one ends", because a hit still interrupts the swing (the take-hit code resets the slash clock).

## 2026-11-22 — The scope was off: from one level to three

- Reading draft 1, I felt it had gone off track (translated): this assignment is mainly a film that tells the professor what our final project will be and how much of it we will make, so he can judge whether the idea is too much to finish or could be more ambitious. Draft 1 talked only about Level 1, which already exists. I suggested following the GDD, with Level 1 as the example, and introducing all six levels so the professor can see the range.
- Claude agreed that the film should show the whole six-level design, but advised against promising all six. By the GDD's own tables, Levels 2–6 need 15 new background layers, five new kinds of enemy and the boss, seven staff frames and 14 story-card illustrations, and the assignment lists "anything needing … an art budget you don't have" as the wrong size. It recommended committing to Levels 1–2.
- I decided on **at least three levels**.
- Draft 2 of PROJECT-BRIEF.md follows that. It has a table of the six designed levels; three tiers (committed: Levels 1–3 with the block, three new enemies, menus, saving and the Web build; if ahead: two villagers, then the staff; out: Levels 4–6, the boss, story cards, world map); the first piece is now Level 2 as a greybox played after Level 1's end card; the risk is now the art for two new levels, with the Web export as the second risk.

## 2026-11-23 — From three levels to all six

- I changed my mind (translated): make it all six levels written in the GDD after all, and let the professor decide whether the amount is right.
- Draft 3 of PROJECT-BRIEF.md proposes all six levels, with the four villagers, the staff, climbing and the boss. The story cards and the world map are out. The assignment asks "Can one person build this by the final? If not, say what you will cut", and it lists "an art budget you don't have" as the wrong size. So draft 3 keeps a cut order: late art ships as a labelled greybox, then the villagers go, then whole levels from the end (6, then 5, then 4), and Levels 1–3 are the floor. Claude said it still expects six levels with their art to be more than one person can finish, and that the cut order lets the reviewer choose.
- Rereading the assignment for this change, Claude found its own mistakes:
  1. Draft 2 left out two parts the text asks for in PROJECT-BRIEF.md: "the game in brief" and "the appendix (with its asset table)". Draft 3 adds both.
  2. Claude had told me the brief must be one page. The text says no such thing.
  3. Claude had not yet raised two requirements:
     - The folder must hold a `GDD.md`, "the game design document the film is built from".
     - The film's second part walks through the GDD in the sixteen sections of the course's Zelda tool. My Assignment 4 GDD has twelve sections and was submitted on Canvas only.
     
     How to handle these is my decision, still open.
- The font's licence is not checked yet. The game ships no font file and uses Godot's built-in one. The asset table says so.

## 2026-11-23 — The GDD goes into the folder

- I decided (translated: "Yes, put it in") that my GDD, restructured into the sections of the course's GDD tool, goes into this folder as `GDD.md`. Until now it had been on Canvas only.
- The tool, Zelda: the old prompt in my local Walker checkout says it has been replaced by the `gdd` skill. That checkout is one commit behind. The newer commit (`a596b23`, 2026-11-21) adds the skill's art and sound commands. Claude read them from the remote without updating the checkout.
- Claude restructured my Assignment 4 GDD (v1) into Zelda's eighteen sections in one pass: metadata, the vision, the sixteen sections, and art and sound.
  - It did not run the skill's commands one at a time, and it signed none of its four human gates.
  - It checked every "built" claim against the code at tag `a7`: speeds, jump numbers, the slash's edges, Rudy's modes, the level's states, layers, input actions and signals.
  - It copied seven of v1's nine figures unchanged into `figures/`, leaving out the cover and the 3D props.
- New in v2 and drafted by Claude, not yet confirmed by me:
  - the player-experience goals and the IDs;
  - the must / should / could tags and the cut order;
  - saving when a level is completed, with best times;
  - Title in place of World map in the pause menu;
  - the new build order;
  - the open questions Q-07 to Q-09.
- Zelda's own scope check: 11 of the 19 features are tagged must (58%), above its 40% warning line. Five of those 11 are what the final-project assignment asks for. The tags were not changed to get under the line; GDD.md section 12 says so.
- PROJECT-BRIEF.md now links to GDD.md, and its "exists today" row for the GDD points here.

## 2026-11-23 — The beat sheet

- I asked Claude to go straight to the beat sheet (translated: "write the beat sheet directly"), before reviewing the GDD items still marked unconfirmed.
- The local Brutalist checkout now matches its remote (`3a6d3979`). On 2026-11-20 it was one commit behind.
- Claude read the toolkit's `show-tell`, `godot-waikthrough` (walker) and `godot-gdd` skills, and the bookend check.
  - Their house bookends use the persona "Liam, in for Bear", the @NikBearBrown handle, a spoken "At Nik Bear Brown" outro, and a Your Turn composer. This assignment forbids the instructor's persona and credit line.
  - The bookend check lets a film exempt the cold open, the verdict and Your Turn, but never the outro, and it takes the outro's handle from `metadata.channel_title`.
  - So the sheet exempts those three bookends, sets the handle to my name, and has the outro read "by Shuai Zhang". The opening is the hesitant writer, in my voice.
  - `bookend_check.py`: PASS. `beat_lint.py`: clean. The gate failure expected on 2026-11-20 did not happen here; the render gates have not run yet.
- The sheet: `tools/make_sheet.py` writes `beat_sheet.json`, and `pitch/` will be the film's working folder. It has 37 beats in the assignment's order:
  - the game in brief;
  - every GDD section, with one beat per level in section 7, as I asked on 2026-11-22;
  - the seven questions, each answered once;
  - the appendix.

  At the toolkit's 2.5 words a second, that is about 9 minutes.
- What each beat shows:
  - **Real play:** only Level 1 at tag `a7`, in five takes still to be captured with scripted input. Each is labelled with its revision and as scripted.
  - **GDD figures:** labelled *constructed* (drawn by code) or *generated*.
  - **18 drawn pictures** still to be made, for the ideas with no game image.
- The game's own audio is muted in every clip. That keeps the ElevenLabs sounds, whose free plan asks for "elevenlabs.io" in the title of anything published with them, out of the film.
- Still unconfirmed by me and spoken in the film: the target role (beat B27) and the player-experience goals (beat B06).

## 2026-11-23 — Shortening the beat sheet

- I asked Claude to shorten the sheet before any capture (translated: "compress it first").
- The rule it was shortened to is the assignment's own: "no fixed length. Keep each beat to one picture and a sentence or two." The first sheet broke it: several beats ran to three, four or five sentences.
- Now every beat has at most two sentences, and `tools/make_sheet.py` refuses to write a beat that has more (the outro is exempt).
  - 37 beats and 1,352 words became 34 beats and 982 words.
  - Length, two estimates, neither measured on this film yet. At the toolkit's 2.5 words a second, 9.0 minutes became 6.6. At 3.42 words a second, the rate Kokoro actually spoke in my Assignment 7 film (2,746 words in 802 s of beat audio), about 6.6 minutes became 4.8.
- Section 7 (world and environment) went from seven beats to four: the map, Level 1 running, Levels 2 to 5 on one beat, and Level 6's boss phases.
  - All six levels are still shown: the Levels 2 to 5 beat uses GDD figure 5, which pictures all six side by side.
  - This undoes the one beat per level I asked for on 2026-11-22, for Levels 2 to 5 only. Claude pointed this out; it can be split again if a level needs its own beat.
- The terms card now has three terms (built, designed, greybox). "Constructed" is no longer explained there, because every constructed picture says "drawn by code, not game art" on screen.
- Claude's miss, fixed here: section 12 of the assignment's GDD table asks for "the smallest version that is playable", and the first sheet left it out. The feature-list beat now says the musts are the smallest complete final.
- The beats after section 7 were renumbered. Still unconfirmed by me and spoken in the film: the target role (now beat B24) and the player-experience goals (still B06).

## 2026-11-23 — Capturing Level 1

- I said "可以，开始录" ("yes, start recording"). Claude Code wrote the film driver and ran the takes; `CAPTURE.md` has the method, the checks and every frame number. I have not watched the clips yet.
- **Three takes, not five.** The beat sheet planned five takes, one per clip. A clean run of the level contains the first three clips' material, so one take (`run`) gives C1, C2 and C4. Then `mech` gives C3, and `pause` gives C5. Fewer windowed takes meant fewer chances for another window to cover the recording.
- **The stomp missed at first.** In the first headless dry run, Rudy jumped clean over goblin A. Claude had worked out the jump's lead from the jump's arc. Its first correction went the wrong way (shorter, so later), which missed again. Measured: 336 px and below cleared the goblin, and 350–400 px stomped it. The driver uses 375.
- **Level 1 is shorter than my design document said.** The clean run took 12.65 s from Enter to the teleport circle; v1 of my GDD said "about 30 s at full speed".
  - GDD.md (sections 6 and 7), PROJECT-BRIEF.md and beat B11 now say about 13 s. The GDD's change table records the measurement.
  - A player who stops or is hit takes longer; the 12.65 s is a run that never stops.
- **A gap in the take check, found and fixed.** `check_take.py` compared the driver's step lines under the prefix `step `, but the driver prints `step:`, so the first check compared none of them. After the fix all three takes still pass, and their step lines equal the dry runs'.
- **A local path in the logs.** Movie Maker's last lines name the scratch folder, which holds my user name and the session's ID. In the committed logs it is replaced by `$CAP`, and `takes.sh` now does that after each take.
- **B11 is sped up.** Its clip is the whole level at 2×: every second frame, at 30 fps. The label on screen says `2× speed`. The assignment names "slowed replays" for labelling; a sped-up clip is labelled for the same reason.

## 2026-11-23 — The pictures

- I said "可以，继续做画面" ("yes, go on with the pictures"). Claude Code drew them. I have not looked at them yet.
- **The toolkit's credit line.** Two components the beat sheet used print "@NikBearBrown", with no prop to change it. This assignment forbids the instructor's name, persona or credit line.
  - `GodotDesignFigure`, the GDD figure card, prints the handle in its bottom-right corner.
  - `ClaudeTitleOutro`, the outro, has the handle hard-coded ("no prop, no lookup, no override", in its own comment).

  So neither is used. The eight figure beats and the outro are drawn as Manim scenes in `scenes.py` instead, and the toolkit is not edited.
  - `bookend_check.py` now fails the outro, because it expects `ClaudeTitleOutro`. This is the failure the 2026-11-20 entry expected. `art run` does not call that check.
  - Its earlier PASS (the beat-sheet entries above) only checked the name typed into the sheet, not what the component draws.
- **The two openers kept from the toolkit** were rendered and looked at. In the hesitant writer and the terms card, the only name on screen is mine.
  - The writer's typing was slowed from 24 to 48 ms a character. That way "one level" shows as the voice says it and turns into "all six levels" about when the voice says "all six". This is to be checked again against the real audio.
- **The pictures.** `scenes.py` is the show-tell kit, pasted unchanged, followed by 27 scenes: 18 drawings, 8 framed figures or stills, and the outro.
  - Every figure carries its status on screen: built, designed, generated or constructed.
  - Beat B08 (systems) was planned as crops of the Level 3 and 4 blockouts. The crops would have been too small to read, so it is a drawing instead: gear, a waystone and a tell lamp.
- **Checked so far:**
  - Each scene was rendered at preview quality and looked at by Claude at 30%, 50% and its last frame. Claude's reading is not my verdict.
  - Two rounds of fixes followed: a slanted plinth; labels hidden behind boxes; a divider running through a label; a check mark drawn over its page's lines; blocks outside their window; a scene with no label at its midpoint.
  - All 27 scenes now pass the toolkit's pre-render checks: Gate A, Gate W and the layout audit.
- **Not done:**
  - the voice;
  - the 4K render;
  - Gates T and V, which run inside `art run`.

  The figures contain small printed text of their own (palette codes, map labels). Gate T may read it as text below its size floor, and nothing has tested that yet.

## 2026-11-23 — The voice

- I said "可以，开始配音" ("yes, start the voice"), which approves the two lines Claude drafted for me and that I had not confirmed yet:
  - the player-experience goals (B06);
  - the target role, gameplay programmer (B24).
- Claude Code voiced all 34 beats with the toolkit's Kokoro script (am_onyx): 318.4 s of narration, 5.31 minutes. The outro has its 1.0 s silent tail (`tools/finish_audio.py`).
- **Pronunciation.** The text sent to the voice was checked phoneme by phoneme (`generate_audio_kokoro.py --phonemize` and the toolkit's respellings). Fixes:
  - **My name.** Kokoro read it "shyoo-eye zhang". `metadata.pronounce` now gives it as shwai jahng, an English approximation of the Mandarin.
  - **"tag a seven".** Read "tag uh seven", so the narration now says "tag A7", read "ay seven".
  - **"Super Mario Bros."** Read "broze", so the narration says "Brothers". The label on screen keeps "Bros.".
  - **"game-AI".** The toolkit's respelling turned it into "gay-muh-eye". Now "my game AI technique from Assignment nine".
  - **The toolkit's own respellings** (`runtime/pronunciation/liam.json`, applied to every am_onyx film) misread four lines of mine. Each was reworded instead of editing the toolkit:
    - "where the web build will live" became "will be hosted";
    - "as the sources file records" became "shows";
    - "the story lives only in the levels" became "the levels alone tell the story";
    - "drops lives" became "has no lives to lose".
  - **Godot** is said go-DOH by that file's choice.
- **Not checked by ear or by transcript.** The toolkit's check is a whisper transcript. No whisper model is on this machine, and downloading one needs my word.
- **Durations and stale audio.**
  - `make_sheet.py` now reads each beat's measured length back into the sheet, so re-running it keeps the audio.
  - It refuses audio whose words changed since it was voiced: it lists such beats as STALE, as it did for B14 and B23 until they were voiced again.
- **Clips.** The clips were re-cut to cover their narration (`CAPTURE.md`, "The clips").
- **Scenes.** Two scenes ran longer than their audio, and the toolkit would have cut them from both ends:
  - B05, 8.20 s against 7.74 s of audio;
  - B17, 9.13 s against 8.70 s of audio.

  Both were tightened. All 27 now end within their audio, still pass Gates A and W and the layout audit, and hold still with a label at their midpoint.
- **The opening.** The hesitant writer turns "one level" into "all six levels" about 0.6–1.5 s before the voice says "all six". This is left as it is for now.

## 2026-11-23 to 24 — Rendering the film

- I said "跳过，直接渲染" ("skip it, render directly"), so the voice was **not** checked with a whisper transcript, only phoneme by phoneme.
- **Paperwork first.** Gate F refuses to render without FACTCHECK.md, SHOTLIST.md and PROMPTS.md.
  - `FACTCHECK.md` has 61 rows, and the toolkit's fact-check gate is clean.
  - SHOTLIST and PROMPTS are written from the beat sheet by `tools/make_docs.py`.
  - Writing the fact check caught two wordings that needed a note:
    - "nothing is bought": no asset was bought, though the Gemini app ran on a paid plan;
    - "the shader and effects are mine": mine in the asset table's sense. The `a6` effects were coded by Claude Code sessions I directed, which B25 says.
- **The play clips nearly became gen-AI placeholders.** With `source: own`, the toolkit's planner files a VIDEO beat as "ask a human for a generated clip". They are now marked `capture` and fill their slots.
  - The compiler does not draw a beat's `label_on_screen`. So `tools/label_clips.py` burns the label (`Level 1 · tag a7 · scripted input`, plus `2× speed` on B11) into every play clip.
- **A false layout warning.** The first `art run` stopped at Gate B because the system Python has no `manim`, so the layout audit crashed. The toolkit counted the crash as a layout warning. Running with the toolkit's conda environment first fixed it.
- **Gate V found 42 defects in the first review cut.** How each kind was handled:
  - **Play clips: declarations in the beat sheet.** Each one is written there with its reason, for a reviewer to check. The frames are the game's own art in mixed colours, so:
    - `full_bleed` (they fill the frame);
    - `contrast_regions` on the label chip;
    - `sparse_by_design` for the game's own fades.
  - **Figure beats:** `contrast_regions` on their status lines.
  - **Drawings: the pictures were changed.**
    - "Designed" objects are pale with ink outlines.
    - Shelves are dark planks.
    - A level's art layer is olive.
    - Several greys are darker.
  - **Too empty at their midpoint:** B16 and B30 got a source line at the bottom.
- **Gate T then blocked ten beats.**
  - **Small text inside the GDD images** (palette codes, frame names, the game's own on-screen text): B00, B12, B15, B16, B26 and B30 declare `typography_regions` around the film's own type, with a reason. The images are content, not this film's type.
  - **The terms card.** The toolkit's `ClaudeDefinitions` sets its meaning text at 40 px at 4K, under Gate T's 41 px floor, and has no size prop. The card is now drawn in `scenes.py` (`BDEFS_Terms`), which is the third toolkit component replaced. One meaning was shortened: "plain shapes, playable before its art".
  - **Smaller fixes:**
    - B21's scale is edged in deep kraft, so it no longer fuses into one "text" blob;
    - B27's shelves are only as long as their crates;
    - the scribbles on B24's and B25's pages are taller.
  - Rewording the card with `sed` also changed the BDEFS narration by mistake. Claude saw the word count drop and restored it before anything was voiced or rendered.
- **The 30 fps final runs Gate V again.** It caught B14 at 85% (contrast 0.30), which the 24 fps review cut had passed. A darker grey fixed it.
- **The master:** `exports/landscape/walker-rudy-final-pitch.mp4`.

  | | |
  | --- | --- |
  | Length | 318.87 s |
  | Picture | 3840 × 2160, 30 fps |
  | Audio | AAC 48 kHz stereo |
  | Loudness | −24.1 LUFS integrated |
  | Ending | the last second is silent |
  | SHA-256 | `48a964f4a59f2b9bf3ab03b10ff15a79ab4ec39a9cadb4969c215554101af1dd`, as in its `.verified.json` |

  All gates passed on it: A, W, B, V and T.
- **The frame rates differ.** The toolkit renders Manim at 24 fps, so in the 30 fps master the drawings repeat one frame in four. The play clips keep every frame.
- **Checked by Claude:** the midpoint frame of every beat in the master. **Not done:** I have not watched it; it is not on Drive; nothing is committed.
- **Expected warnings.** Two bookend warnings remain, because the opening is not the house composer and the outro is not `ClaudeTitleOutro`. `bookend_check.py` fails the outro for the same reason. Both are expected (see "The pictures").

## 2026-11-24 — Watching, the upload and the last documents

- I watched the whole film and said "看完了，没问题，已经传到了googledrive" ("I've watched it, no problem, and it's uploaded to Google Drive"), with the link.
- **The link.** Claude opened it without signing in: the page names `walker-rudy-final-pitch.mp4` and asks for no access. Claude did not download the file, so the SHA-256 in the README is the local master's, recomputed from the file the same day.
- **The last three documents**, written by Claude from Assignment 8's "What to submit" list:
  - `README.md`: my name, the working title, the target role, the runtime, the link with its filename and SHA-256, a map from each part of the assignment to its beats, the gate results with their limits, and how to rebuild;
  - `BUILD-PROMPT.md`: the paste-ready prompt and every command used to build the film. Claude checked that the capture copy's patch still applies to a fresh archive of `a7`. The film has **not** been rebuilt from a clean clone;
  - `SOURCES.md`: who did what, what each picture is made from, and every asset's licence.
- **Licences checked:**
  - **The game's font**, the one open item in my asset table: the game ships no font file, and Godot 4.7.2's own copyright list names its default font as Open Sans SemiBold, under the SIL Open Font License 1.1. `PROJECT-BRIEF.md` and `GDD.md` (Q-06) now say so.
  - **The film's font**, EB Garamond: the same licence, read from the font file.
  - **The voice:** Kokoro-82M is Apache 2.0 and kokoro-onnx is MIT, read from their published pages.
- **Found while writing, and fixed:**
  - `SHOTLIST.md` still said two toolkit components were replaced and two toolkit cards kept. It is three replaced (the terms card too) and one kept; `tools/make_docs.py` now says so.
  - The brief still said the target role was "to be confirmed". I approved it with the narration on 2026-11-23, so it now says confirmed.
  - `CAPTURE.md` still said I had not watched the clips.
- **Found while writing, and written down instead of re-rendered**, since I had already approved the film:
  - **Gate T skipped the five play-clip beats** ("no video"). Their only type is the label chip, which is 96 px, over twice the floor, and Gate V checked its contrast.
  - **The layout audit report** covers only the scenes re-rendered in the last round.
  - **B24 has no label of its own on Rudy's generated running frame.** B15 labels the same frame.
- **What goes into git.** The folder's `.gitignore` now also leaves out the toolkit's working files: the clips folder, the review cut's contact sheet and the slot to-do lists. The gate reports and `STATUS.md` are kept.
- **Still not done:**
  - I have not reviewed `FACTCHECK.md` row by row;
  - several rows of the GDD's change table still say "not yet confirmed by me".
- **Committed.** I said "可以，提交推送" ("yes, commit and push"). This folder is committed as it stands and tagged `a8`. The commit's hash is in my Canvas submission, since a file cannot name its own commit.

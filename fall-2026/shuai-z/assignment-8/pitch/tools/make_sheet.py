#!/usr/bin/env python3
"""make_sheet.py — writes ../beat_sheet.json, the plan for the Assignment 8 pitch film.

Drafted by Claude Code (Claude Opus 5.5) on 2026-11-23 from PROJECT-BRIEF.md (draft 3) and
GDD.md (v2); Shuai Zhang reviews it. Rerun it after editing; never after the final render
(it would wipe the build stamps; see the show-tell skill).

The film follows Assignment 8's order: the game in brief, the GDD section by section, the seven
questions (each answered once; 1 is answered in the brief, 5's in/out in the feature and
out-of-scope beats, 6 in the risks beat), then the appendix. Section 7 (world and environment)
takes four beats so that all six levels are seen: the map, Level 1 running, Levels 2 to 5, and
Level 6.

Length. Assignment 8: "no fixed length. Keep each beat to one picture and a sentence or two."
So every beat's narration is at most two sentences, and the script refuses one that is longer.
Revision 2 (2026-11-23, at Shuai's request to shorten the first sheet): 37 beats and 1,352 words
became 34 beats and 982; the four Level 2 to 5 beats became one beat on GDD.md figure 5; the
"constructed" term moved off the terms card (each constructed picture says so on screen).
Two estimates are printed: the show-tell skill's 2.5 words a second (the estimated_duration_s
field), and 3.42 words a second, the rate Kokoro am_onyx actually spoke in the Assignment 7
film (2,746 words in 802 s of beat audio, measured 2026-11-23).

Formats: show-tell (one picture per beat, few words on screen, the voice explains). Three kinds
of picture:
  - VIDEO:   real captured play of Level 1 at tag a7, scripted input, labelled as such;
  - figure:  a Manim scene that shows a figure from GDD.md or a still from a take (generated art
             or a code-drawn blockout), with its status written on screen (built, designed,
             generated, constructed);
  - manim:   a drawn isometric picture for an idea that has no game image yet.
Every body picture is a Manim scene in scenes.py. The toolkit's GodotDesignFigure card and its
ClaudeTitleOutro both print "@NikBearBrown" with no way to change it (GodotDesignFigure.tsx and
ClaudeTitleOutro.tsx, checked 2026-11-23), which Assignment 8 forbids, so neither is used: the
figures and the outro are drawn in scenes.py instead, and the toolkit is not edited.
The narration speaks as me, in a synthetic voice (Kokoro am_onyx). Assignment 8 forbids the
instructor's name, persona or credit line, so there is no "Liam, in for Bear", no
@NikBearBrown handle, and the outro is read as "by Shuai Zhang".
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from chip import text_region  # noqa: E402  (the label chip's place on screen, shared with label_clips.py)

PITCH = Path(__file__).resolve().parent.parent
SLUG = "walker-rudy-final-pitch"
TITLE = "Walker Rudy: The Long Way Home. A Final Project Pitch"
HANDLE = "Shuai Zhang"
A7 = "76206412267f07569b1488c9a9f4db03efa352a2"
LIVE_LABEL = "Level 1 · tag a7 · scripted input"
CONSTRUCTED = "constructed: drawn by code, not game art"
GENERATED = "generated (Gemini app, Assignment 2)"
MAX_SENTENCES = 2

SPARSE = ("show-tell: one drawn picture on a cream stage per beat, with the voice carrying the "
          "explanation; only underfill and clustered are waived.")


def est(text):
    return round(len(text.split()) / 2.5, 1)


def sentences(text):
    """Count sentences the way a listener hears them: '.', '?' or '!' followed by a space or the end.
    Abbreviations that end in '.' mid-sentence ('Bros.') are not sentence ends."""
    t = text.replace("Bros.", "Bros")
    return sum(1 for i, c in enumerate(t) if c in ".?!" and (i + 1 == len(t) or t[i + 1] == " "))


def base(bid, act, narration, shot, **extra):
    b = {"beat_id": bid, "act": act, "narration_text": narration,
         "estimated_duration_s": est(narration), "voice": "am_onyx", "engine": "kokoro", "shot": shot}
    b.update(extra)
    return b


def manim(bid, act, narration, cls, picture, show, labels):
    return base(bid, act, narration,
                {"type": "GRAPHIC", "source": "own", "visual_intent": picture, "motion_claim": picture,
                 "show": show, "labels": labels, "manim": {"class": cls}},
                lane="manim", proof_gate="SHOW", qc={"sparse_by_design": True, "sparse_reason": SPARSE})


def band(y, x0=0.1, x1=0.9, h=0.62):
    """A Gate V contrast region around a line of text at Manim height y (the frame is 14.22 x 8 units)."""
    return [x0, round((4 - y - h / 2) / 8, 4), x1, round((4 - y + h / 2) / 8, 4)]


def figure(bid, act, narration, title, status, image, image_from, cards, source, cls, regions=None, typography=None):
    """A figure beat, drawn by scenes.py class `cls`: the image framed on the stage, its status line
    (built / designed / generated / constructed) and its labels on screen. No sparse waiver: a framed
    figure fills the frame on its own."""
    return base(bid, act, narration,
                {"type": "GRAPHIC", "source": "own", "manim": {"class": cls},
                 "figure": {"title": title, "status": status, "image": image, "image_from": image_from,
                            "labels": [{"label": l, "text": t} for l, t in cards], "source": source},
                 "visual_intent": f"{title}: {image}, framed, with its status on screen"},
                lane="manim", proof_gate="SHOW",
                qc={**({"contrast_regions": regions,
                        "contrast_reason": ("the figure is a full-colour image from GDD.md; the text that must be "
                                            "read is the scene's own ink type on the cream stage, so that is "
                                            "what is measured")} if regions else {}),
                    **({"typography_regions": typography, "typography_reason": ("mixed source imagery: the framed figure is a GDD image whose own small labels (palette codes, frame names, the game's on-screen text) are image content, not this film's type; the scene's own type is inventoried in the declared regions")} if typography else {})})


def video(bid, act, narration, clip, take, frames, route, observation, speed=1, anchor="end"):
    """A cut of one Movie Maker take (capture/takes.sh, 30 fps): `frames` is [first, end) in the take's own
    frame numbers, which equal its log's "frame N" lines (capture/check_take.py). `speed` above 1 is a
    sped-up cut, and the label on screen says so. `frames` is the planned window; tools/cut_clips.py fits the
    cut to the beat's measured audio by keeping the `anchor` end of the window (the start, or the end) and
    moving the other end, and logs the frames it used in capture/logs/cut_clips.txt."""
    label = LIVE_LABEL + (f" · {speed}× speed" if speed != 1 else "")
    return base(bid, act, narration,
                {"type": "VIDEO", "lane": "evidence", "source": "capture", "treatment": "none",
                 "speed_note": None if speed == 1 else f"{speed}x speed: every {speed}nd frame of the take, at 30 fps",
                 "evidence_media": f"clips/{clip}.mp4", "slot": f"media/{bid}.mp4 (tools/label_clips.py: the clip "
                 "with its label burned in)",
                 "capture_plan": {"clip": clip, "take": take, "take_file": f"capture/take-{take}.mp4",
                                  "frames": frames, "anchor": anchor, "seconds_in_take": round((frames[1] - frames[0]) / 30, 2),
                                  "speed": speed, "game": "fall-2026/shuai-z/assignment-7/game",
                                  "revision": A7, "method": "Godot Movie Maker at 30 fps on an isolated copy "
                                  "(git archive a7), input pressed by capture/film_driver.gd, adapted from "
                                  "Assignment 7's (it presses the game's input actions only; it never moves, "
                                  "places or sets anything)",
                                  "route": route, "game_audio": "not used: the clip is video only"},
                 "label_on_screen": label, "observation": observation},
                lane="evidence", proof_gate="SHOW",
                qc={"full_bleed": True, "sparse_by_design": True,
                    "sparse_reason": ("real captured play fills the frame edge to edge, and the game's own fades "
                                      "(a fall, the last heart, the end card) leave frames nearly empty; that is the "
                                      "game, not a layout"),
                    "contrast_regions": [{"label": "the label chip (level, tag, scripted input)",
                                          "box": text_region(label)}],
                    "contrast_reason": ("the frame is the game's own painted art in mixed colours; the text that "
                                        "must be read is the label chip, ink on cream, so that is what is measured")})


def remotion(bid, act, narration, pattern, props, show, gate="SHOW", **extra):
    return base(bid, act, narration,
                {"type": "REMOTION", "source": "own", "show": show,
                 "remotion": {"pattern": pattern, "props": props}},
                lane="bookend", proof_gate=gate, **extra)


OPEN = [
    remotion("BIDEA", "opening",
             "I'm Shuai Zhang, and this is my final project pitch: Walker Rudy. "
             "One level exists, and I am proposing all six, so that you can judge whether that is the right size.",
             "BrutalistHesitantWriter",
             {"text": "My final project:\nWalker Rudy, one level", "triggerWords": "one level",
              "replacementWords": "all six levels", "fontSize": 96, "charMs": 48, "hesitateBetween": 4,
              "hesitateWithin": 1, "mistakeRate": 2, "jitter": 8, "seed": SLUG, "banner": ""},
             [{"at": 0.0, "event": "types 'My final project: Walker Rudy, one level'"},
              {"at": 0.6, "event": "'one level' backspaces into 'all six levels' on 'I am proposing all six'"}],
             lead_silence_s=0.8,
             motion_claim="The writer types the one level that exists and corrects it to the six that are proposed.",
             qc={"sparse_by_design": True, "sparse_reason": "Hesitant-writer opening: the correction is the motion."}),
    figure("B00", "title card: the GDD's metadata",
           "This film follows my design document, version two, dated November the twenty-third, "
           "read by a synthetic voice from a script Claude Code drafted with me.",
           "Walker Rudy: The Long Way Home",
           "GDD v2 (draft) · 2026-11-23 · Shuai Zhang · CSYE 7270 · narration: synthetic voice (Kokoro), speaking for me",
           "stills/title.png", "the first frame of take C1: the game's own title screen at tag a7",
           [("Genre", "2D action platformer"), ("Engine", "Godot 4.7.2"), ("Target", "Web")],
           "Source: GDD.md §0 (v2, 2026-11-23); still from take C1 at tag a7.", "B00_Title",
           typography=[{"label": "title", "box": band(2.85, 0.1, 0.9)}, {"label": "GDD version, date, name, voice", "box": [0.662, 0.29, 0.894, 0.72]}, {"label": "the still's caption", "box": [0.057, 0.769, 0.57, 0.844]}]),
    base("BDEFS", "terms",
         "Built means you will see it running at tag A7; designed means it is only in my document. "
         "A greybox is a level of plain shapes, playable before its art.",
         {"type": "GRAPHIC", "source": "own", "manim": {"class": "BDEFS_Terms"},
          "terms": [{"term": "built", "meaning": "shown running: the game, tag a7"},
                    {"term": "designed", "meaning": "planned: the design document only"},
                    {"term": "greybox", "meaning": "plain shapes, playable before its art"}],
          "visual_intent": "Terms in this film: three rows, each term with its one-line meaning, landing as it is said",
          "show": [{"at": 0.1, "event": "'built'"}, {"at": 0.45, "event": "'designed'"}, {"at": 0.75, "event": "'greybox'"}],
          "role_note": ("drawn in scenes.py instead of the toolkit's ClaudeDefinitions: that card's meaning text "
                        "measures 40 px at 4K, under GATE T's 41 px floor, and it has no size prop")},
         lane="manim", proof_gate="CARD",
         qc={"sparse_by_design": True, "sparse_reason": "terms card: three rows that land one at a time"}),
]

BRIEF = [
    video("B01", "the game in brief: what it is",
          "Walker Rudy is a side-scrolling platformer: as Rudy, a young mage, you run, jump, stomp and fight with a sword. "
          "This is level one at tag A7, played by a script.",
          "C1", "run", [0, 290],
          "the title; Enter (frame 45); the first spikes jumped; goblin A stomped (142); the sword picked up (175); "
          "goblin B slashed (216); the waystone lit (256)",
          "Real play of Level 1: the title fades, Rudy runs, jumps the spikes, stomps a goblin, picks up the sword "
          "and slashes the next goblin.", anchor="start"),
    video("B02", "the game in brief: the goal",
          "Each level ends at a teleport circle, and beating the archmage Aldric Voss in level six wins the game. "
          "Losing your last heart only restarts the level.",
          "C2", "run", [300, 541],
          "from just after the waystone lights (cut fitted to the narration: from frame 262): the first cliff; the "
          "second spikes; goblin C slashed (360); the second cliff; the teleport circle (425); the celebration; "
          "the end card (495)",
          "Real play: Rudy clears the last stretch, reaches the teleport circle, and the end card appears."),
    manim("B03", "question 1: what exists when it is done",
          "Done, the final will be all six levels, from a title menu to an end screen, "
          "exported to the web with a test report anyone can rerun.",
          "B03_SixTiles",
          "Six level tiles in a row: the first kraft (built), five pale (designed); a browser window draws around them; a test page lands and its two boxes are ticked.",
          [{"at": 0.15, "event": "six tiles, one solid"}, {"at": 0.5, "event": "into a browser window"},
           {"at": 0.8, "event": "test report with a check"}],
          ["level 1", "web", "test report"]),
]

GDD = [
    manim("B04", "GDD 1: design pillars",
          "Four pillars: your gear is your plan, read every threat, it stings and then you try again, "
          "and a journey into another world.",
          "B04_FourPillars",
          "Four pillars rise one by one under a lintel, each on its spoken name.",
          [{"at": 0.2, "event": "gear"}, {"at": 0.4, "event": "tells"}, {"at": 0.6, "event": "retry"},
           {"at": 0.8, "event": "journey"}],
          ["gear", "tells", "retry", "journey"]),
    manim("B05", "GDD 2: core gameplay loop",
          "Second to second, you choose to jump, stomp or fight; over a level, you choose your gear and your detours; "
          "and the next region pulls you on.",
          "B05_ThreeLoops",
          "Three rings side by side, growing in size: a dot circles the small one; the middle one gets a gear stand and a side path; on the large one a dot travels up to the next region's tile.",
          [{"at": 0.15, "event": "small ring spins"}, {"at": 0.5, "event": "middle ring: stand, detour"},
           {"at": 0.85, "event": "large ring reaches the next tile"}],
          ["seconds", "a level", "next region"]),
    manim("B06", "GDD 3: player experience goals",
          "The player should feel warned in time before every attack, and stung but ready to retry after a mistake. "
          "I will check both in playtests, with the sound on and off.",
          "B06_Feelings",
          "A tell lamp lights before a shot leaves; then a heart drops and a retry arrow loops back; a playtest page with two boxes ticks.",
          [{"at": 0.2, "event": "lamp, then shot"}, {"at": 0.5, "event": "heart drops, retry loop"},
           {"at": 0.8, "event": "playtest page ticks"}],
          ["warned", "try again", "playtest"]),
    video("B07", "GDD 4: core mechanics, with losing and restarting",
          "A slash can't restart until it ends, a hit knocks the sword away before it costs a heart, "
          "and a fall returns Rudy to the last waystone. Block, staff and climbing are designed, not built.",
          "C3", "mech", [205, 516],
          "goblin B slashed (216); the waystone lit (256); the first cliff and the second spikes; goblin C's touch "
          "knocks the sword away (363); its next touch costs a heart (399); a run off the second cliff, which costs "
          "a heart (451); Rudy gets up at the waystone (469) and is in control again (489)",
          "Real play: a slash; the waystone lights; a hit sends the sword flying; the next costs a heart; a fall, and Rudy gets up at the waystone."),
    manim("B08", "GDD 5: systems",
          "Gear protects your hearts, waystones keep your place, and every enemy shows a tell before it attacks. "
          "One enemy will run on my game AI technique from Assignment nine.",
          "B08_Systems",
          "Three parts on one floor: a shield in front of three hearts turns a hit aside; a waystone's light comes on; "
          "a lamp lights before an arrow leaves. Then a dashed crate marked A9 lands beside the lamp.",
          [{"at": 0.15, "event": "the shield turns a hit"}, {"at": 0.3, "event": "the waystone lights"},
           {"at": 0.45, "event": "the lamp, then the arrow"}, {"at": 0.75, "event": "the A9 crate lands"}],
          ["gear", "waystone", "tell", "A9"]),
    manim("B09", "GDD 6: progression",
          "Each level adds an idea or two: the block in level three, the staff and ropes in level four, "
          "and Rudy's hearts rising from three to seven.",
          "B09_Staircase",
          "Six steps rise left to right; a shield lands on step 3, a staff and a rope on step 4; a heart counter climbs from 3 to 7.",
          [{"at": 0.2, "event": "steps rise"}, {"at": 0.5, "event": "shield on 3, staff and rope on 4"},
           {"at": 0.85, "event": "hearts 3 → 7"}],
          ["block", "staff", "hearts"]),
    figure("B10", "GDD 7: world and environment",
           "Rudy's village sits in a farming kingdom, across the sea from a grey continent of ash, forest and desert, "
           "and his road home crosses six regions.",
           "The world, and the road home", f"Designed · {CONSTRUCTED}",
           "figures/world-map.png", "GDD.md figure 4",
           [("West", "the Ashen Reach"), ("East", "Aldmere, Ambervale"), ("Route", "levels 1 to 6")],
           "Source: GDD.md §7, figure 4 (code-drawn, Assignment 4).", "B10_World",
           regions=[{"label": "the status line", "box": band(-2.9)}]),
    video("B11", "GDD 7: Level 1, built",
          "Level one, Harvest Fields, is built: three goblins, two sets of spikes, two cliffs, the sword and a waystone, "
          "about thirteen seconds at full speed.",
          "C4", "run", [45, 541],
          "the whole level, from the title's last second and Enter (frame 45) to the teleport circle (425) and the end card (495): "
          "12.65 s (759 physics ticks) from Enter to the circle",
          "Real play: all of Level 1, from the title to the end card, at twice its speed.", speed=2),
    figure("B12", "GDD 7: Levels 2 to 5, designed",
           "Levels two to five are designed, and each adds new enemies and hazards: a beetle and falling ledges; "
           "mushrooms, scorpions and quicksand; archers, ropes and the staff; shield guards and an avalanche.",
           "The six levels",
           f"Level 1: in-game screenshot · Levels 2–6: designed · {CONSTRUCTED}",
           "figures/levels.jpg", "GDD.md figure 5",
           [("Level 2", "beetle · falling ledges"), ("Level 3", "mushrooms · scorpions · quicksand"),
            ("Level 4", "archers · ropes · staff"), ("Level 5", "guards · avalanche")],
           "Source: GDD.md §7, figure 5. Level 1 is a screenshot; Levels 2–6 are drawn by code (Assignment 4).", "B12_Levels",
           typography=[{"label": "the status line", "box": band(-2.95, 0.04, 0.96)}],
           regions=[{"label": "the status line", "box": band(-2.95, 0.04, 0.96)}]),
    figure("B13", "GDD 7: Level 6, designed",
           "Level six is home, where the archmage Aldric Voss fights in three phases, and every attack glows before it lands.",
           "Level 6: Ambervale, after", f"Designed · {CONSTRUCTED}",
           "figures/boss-phases.jpg", "GDD.md figure 2",
           [("Phase 1", "amber volleys"), ("Phase 2", "shards, spike lines"), ("Phase 3", "the floor crumbles")],
           "Source: GDD.md §5 S-05 and §7. Diagrams drawn by code (Assignment 4).", "B13_Boss",
           regions=[{"label": "the status line", "box": band(-1.75)}]),
    manim("B14", "GDD 8: narrative",
          "The design tells the story on fourteen painted cards between levels; "
          "those are out, so the levels alone tell the story.",
          "B14_Cards",
          "Five story cards in a row, labelled 14 story cards, slide into a crate marked out; then a level strip appears and a castle, a ridge with a light and a crater rise on it in turn.",
          [{"at": 0.2, "event": "cards fan"}, {"at": 0.45, "event": "set aside"},
           {"at": 0.75, "event": "castle, ridge, crater light"}],
          ["story cards", "out"]),
    figure("B15", "GDD 9: characters",
           "Rudy is ten, a gifted mage only fair with a sword, here in his generated frames. "
           "Against him stands Voss, and four lost villagers wait along the way.",
           "Characters", f"Built frames · {GENERATED}",
           "figures/rudy.jpg", "GDD.md figure 6",
           [("Rudy", "the player, ten"), ("Voss", "the boss"), ("Villagers", "four, levels 2–5")],
           "Source: GDD.md §9, figure 6. Images generated in the Gemini app (Assignment 2).", "B15_Rudy",
           typography=[{"label": "the name and status column", "box": [0.57, 0.15, 0.95, 0.72]}]),
    figure("B16", "GDD 10: art direction",
           "Flat, outlined characters on soft painted backgrounds, so anything that can hurt you reads at once. "
           "Two planned colours sit close to Rudy's outline, so they stay away from where he plays.",
           "Art direction", f"Built · {GENERATED}",
           "figures/cast.jpg", "GDD.md figure 7",
           [("Characters", "flat, 4 px outline"), ("Backgrounds", "painted, muted"), ("Weakest", "1.87 and 2.00")],
           "Source: GDD.md §10. Images generated in the Gemini app (Assignment 2); contrast numbers from v1's check.", "B16_Palette",
           typography=[{"label": "the status line", "box": band(-0.05, 0.2, 0.8)}, {"label": "swatch labels, note and source", "box": [0.04, 0.6875, 0.96, 0.935]}]),
    manim("B17", "GDD 11: sound and music",
          "A folk theme from Suno and six sound effects from Adobe Firefly and ElevenLabs, "
          "each with a visual twin, so the game reads with the sound off.",
          "B17_Twins",
          "A speaker and an eye side by side; each sound wave that leaves the speaker lights a matching shape by the eye; a muted speaker, and the shapes still light.",
          [{"at": 0.3, "event": "wave lights a twin"}, {"at": 0.75, "event": "muted, twins still light"}],
          ["sound", "visual twin"]),
    manim("B18", "GDD 12: feature list (question 5: in)",
          "The musts are the smallest complete final: levels one to three, block, menus, saving, web build and test report. "
          "Should: levels four to six, staff, climbing, boss; could: villagers and finished art.",
          "B18_Shelves",
          "Three shelves labelled must, should, could; boxes drop onto each as they are named.",
          [{"at": 0.2, "event": "must shelf fills"}, {"at": 0.65, "event": "should shelf fills"},
           {"at": 0.9, "event": "could shelf fills"}],
          ["must", "should", "could"]),
    manim("B19", "GDD 13: out of scope (question 5: out)",
          "What it will deliberately not do: the painted story cards, the three-D world map, and new music for each region.",
          "B19_Out",
          "Three boxes slide off a shelf into a crate marked 'out': a card stack, a small globe, a music page.",
          [{"at": 0.3, "event": "cards out"}, {"at": 0.55, "event": "map out"}, {"at": 0.8, "event": "music out"}],
          ["out"]),
    manim("B20", "GDD 14: technical requirements",
          "Godot four point seven point two, the Compatibility renderer, a web export at sixty frames a second, "
          "and every level a greybox before its art.",
          "B20_Greybox",
          "A grey level of plain blocks; a browser frame around it; a paint layer slides over the blocks from left to right.",
          [{"at": 0.25, "event": "browser frame"}, {"at": 0.55, "event": "60 fps dial"},
           {"at": 0.8, "event": "art layer slides over the greybox"}],
          ["web", "60 fps", "greybox"]),
    manim("B21", "GDD 15: risks (question 6)",
          "What could sink it is art: fifteen backgrounds, plus sprites for five enemies and the boss. "
          "So every level will play as a greybox first, and I will test the web export early, on level one.",
          "B21_ArtRisk",
          "Fifteen background sheets pile up on one side of a scale and tip it; five grey level tiles slide under the other side and level it; a browser icon checks level one.",
          [{"at": 0.25, "event": "sheets pile, scale tips"}, {"at": 0.6, "event": "greyboxes level it"},
           {"at": 0.85, "event": "level 1 in a browser"}],
          ["art", "greybox"]),
    manim("B22", "GDD 16: open questions",
          "Still open: whether seven hearts make the boss too easy, how the staff's barrier differs from the shield, "
          "and where the web build will be hosted. The design says how I'll find out.",
          "B22_Questions",
          "Three pages with question marks; under each, a small tool appears (a playtest, a test, a browser).",
          [{"at": 0.2, "event": "three questions"}, {"at": 0.7, "event": "a way to find out under each"}],
          ["boss", "barrier", "hosting"]),
]

QUESTIONS = [
    manim("B23", "question 2: why anyone would care",
          "In Super Mario Brothers and New Super Mario Brothers, which I've played, a hit takes your power-up first. "
          "Walker Rudy keeps that, adds a committed sword swing, and has no lives to lose, so a mistake never ends the game.",
          "B23_Compare",
          "Two plain columns (no game art): a shared row 'hit takes the power-up first'; on Rudy's side a sword arc and a lives counter crossed out.",
          [{"at": 0.3, "event": "shared rule row"}, {"at": 0.65, "event": "sword arc"},
           {"at": 0.85, "event": "lives crossed out"}],
          ["power-up first", "sword", "no lives"]),
    manim("B24", "question 3: who opens it",
          "It is for you, my instructor and the teaching assistants; the target role is gameplay programmer. "
          "Within a minute, you will follow the read-me's link to the web build and be playing.",
          "B24_FirstMinute",
          "A README page; the target role appears; a link line draws to a browser window where Rudy's own run frame crosses the ground while a clock hand sweeps one minute.",
          [{"at": 0.3, "event": "README"}, {"at": 0.6, "event": "link to browser"}, {"at": 0.85, "event": "one minute, playing"}],
          ["README", "web build", "1 min"]),
    manim("B25", "question 4: what it proves",
          "It proves a shader I wrote, particle effects and animation states, each at its tag with tests anyone can rerun. "
          "Claude Code sessions I scoped and reviewed wrote most of the code, as the sources file shows.",
          "B25_Tags",
          "Three crates tagged a5, a6, a7 land on a shelf, each with a test page and a check; a sources page lands last.",
          [{"at": 0.2, "event": "a5"}, {"at": 0.4, "event": "a6"}, {"at": 0.6, "event": "a7"},
           {"at": 0.85, "event": "sources page"}],
          ["a5", "a6", "a7"]),
    manim("B26", "question 5: what comes first",
          "First comes level two as a greybox, straight after level one's end card. "
          "You will know it ran because a headless test walks Rudy into it and checks the ledge timings.",
          "B26_FirstPiece",
          "Level 1's end card slides left; a grey level slides in; a ledge cracks and falls on a timer; a test page ticks.",
          [{"at": 0.2, "event": "end card → greybox"}, {"at": 0.55, "event": "ledge cracks, falls"},
           {"at": 0.85, "event": "test ticks"}],
          ["level 2", "greybox", "test"]),
    manim("B27", "question 7: why this project",
          "Mostly to learn: I had none of these skills before this semester. "
          "New in the final: greybox levels, enemies that decide for themselves, a boss, menus, saving and a web export.",
          "B27_Learn",
          "The a5–a7 crates on their shelf; six empty dashed crates appear on a new shelf above, one per new skill.",
          [{"at": 0.25, "event": "learned shelf"}, {"at": 0.6, "event": "new shelf, six dashed crates"}],
          ["learned", "new"]),
]

APPENDIX = [
    video("B28", "appendix: what exists, started, not started",
          "What exists today is level one at tag A7, all the play in this film. "
          "Rudy's block frame is generated but not in play, and levels two to six are not started.",
          "C5", "pause", [60, 358],
          "a short run; Esc: 'Paused' (frame 86); Esc: resume (122); the first spikes; goblin A's touches cost a "
          "heart each (192, 228); the third takes the last heart (276); the level starts over at the start with "
          "full hearts (311), in control again (331)",
          "Real play: the pause, then the last heart lost and Level 1 starting over."),
    manim("B29", "appendix: can one person build it",
          "Can one person build all this by the final? I'm not sure; if it won't fit, late art becomes greybox, "
          "then villagers go, then levels six, five and four, and one to three are the floor.",
          "B29_Floor",
          "Six tiles with art tops, villager dots on 2–5, under the label cut order: the art on tiles 4–6 turns grey, the dots lift off, tiles 6, 5, 4 slide away, and a floor line is drawn under tiles 1–3.",
          [{"at": 0.3, "event": "art → greybox"}, {"at": 0.6, "event": "villagers off"},
           {"at": 0.85, "event": "6, 5, 4 cut; 1–3 stay"}],
          ["floor", "cut order"]),
    figure("B30", "appendix: where every asset comes from",
           "Images come from Gemini, sound from Firefly and ElevenLabs, music from Suno, all generated. "
           "The shader and effects are mine, nothing is bought, and every licence is in the sources file.",
           "Where every asset comes from", "Appendix · PROJECT-BRIEF.md asset table",
           "figures/level-1.jpg", "GDD.md figure 1 (in-game screenshots of generated art), beside the table's rows",
           [("Images", "Gemini · generated"), ("Sound", "Firefly, ElevenLabs · generated"),
            ("Music", "Suno · generated"), ("Shader, effects", "mine")],
           "Source: PROJECT-BRIEF.md appendix; Assignment 2 SOURCES.md for each licence.", "B30_Assets",
           typography=[{"label": "the status line", "box": band(-1.2, 0.09, 0.59)}, {"label": "the source line", "box": band(-3.0, 0.12, 0.71)}, {"label": "the asset column", "box": [0.641, 0.156, 0.95, 0.825]}],
           regions=[{"label": "the asset column", "box": [0.66, 0.16, 0.95, 0.62]}]),
]

OUT = base("BOUT", "outro", f"{TITLE}. By {HANDLE}.",
           {"type": "GRAPHIC", "source": "own", "manim": {"class": "BOUT_Title"},
            "show": [{"at": 0.0, "event": "the title"}, {"at": 0.6, "event": "By Shuai Zhang"}],
            "outro": {"title": TITLE, "handle": HANDLE, "subline": ""}},
           lane="manim", proof_gate="SHOW", kind="outro_voice", tail_silence_s=1.0,
           qc={"sparse_by_design": True, "sparse_reason": "the outro is a title card: the title, then my name"},
           role_note=("Assignment 8: no instructor name, persona or credit line. The toolkit's ClaudeTitleOutro "
                      "prints @NikBearBrown and cannot be changed, so the outro is drawn in scenes.py (BOUT_Title) "
                      "with the title and my name, and read 'by Shuai Zhang'. bookend_check.py, which expects "
                      "ClaudeTitleOutro, therefore fails this beat by design (FRICTIONAL.md)."))
OUT["estimated_duration_s"] = 5.0

beats = OPEN + BRIEF + GDD + QUESTIONS + APPENDIX + [OUT]

# B26 is a drawing, but it frames a still of the game's end card, whose own "Level complete" text is image content.
for b in beats:
    if b["beat_id"] == "B26":
        b["qc"].update({"typography_regions": [
            {"label": "end of level 1", "box": band(-0.85, 0.13, 0.36)},
            {"label": "level 2 greybox", "box": band(-2.3, 0.54, 0.84)},
            {"label": "headless test", "box": band(2.35, 0.57, 0.81)}],
            "typography_reason": ("mixed source imagery: the framed still is the game's end card at tag a7, whose "
                                  "own text is image content; the scene's own labels are the declared regions")})

ids = [b["beat_id"] for b in beats]
assert len(ids) == len(set(ids)), "duplicate beat ids"
too_long = [(b["beat_id"], sentences(b["narration_text"])) for b in beats
            if b["beat_id"] != "BOUT" and sentences(b["narration_text"]) > MAX_SENTENCES]
assert not too_long, f"Assignment 8 asks for a sentence or two per beat; over: {too_long}"

sheet = {"metadata": {
    "slug": SLUG, "title": TITLE, "topic": "WALKER-RUDY · FINAL PROJECT PITCH",
    "skill": "show-tell", "style_preset": "show-tell", "channel": "walker-rudy", "channel_title": HANDLE,
    "persona": "Shuai Zhang, in a synthetic voice (Kokoro am_onyx); not Liam, and not in for anyone",
    "in_for_bear": False, "voice": "am_onyx", "voice_kokoro": "am_onyx", "engine": "kokoro",
    "pronounce": {"Shuai": "ʃwˈaɪ", "Zhang": "dʒˈɑːŋ"},
    "pronounce_note": ("voice only: my name in an English approximation of the Mandarin (shwai, jahng); Kokoro's "
                       "G2P read it 'shyoo-eye zhang'. The toolkit's am_onyx respellings (pronunciation/liam.json) "
                       "also apply, so the narration avoids the words they misread here: 'will live' at a "
                       "sentence end, and 'records' as a verb."),
    "clock": "narration", "palette": "claude", "register": "plain", "fps": 30, "aspect_ratio": "16:9",
    "width": 3840, "height": 2160, "caption_policy": "none",
    "bookend_exempt": ["cold-open", "bvdt", "bhtf"],
    "bookend_exempt_reason": ("Assignment 8 sets the film's order (the game in brief, the GDD, the seven questions, "
                              "the appendix) and says AI narration speaks as the student, without the instructor's name, "
                              "persona or credit line. So the opening is the hesitant writer in my voice, there is no "
                              "verdict card and no Your Turn, and the outro carries my name."),
    "length_rule": ("Assignment 8: 'no fixed length. Keep each beat to one picture and a sentence or two.' "
                    "make_sheet.py refuses a beat over two sentences (the outro is exempt)."),
    "sheet_revision": "2 (2026-11-23): shortened from 37 beats to 34, each at most two sentences",
    "audience": "my instructor and TAs, judging whether the final project's scope fits one person",
    "source_doc": "GDD.md v2 (2026-11-23); PROJECT-BRIEF.md draft 3 (2026-11-23); Assignment 8 text (Canvas, pasted 2026-11-20)",
    "gdd": {"path": "GDD.md", "version": "v2 (draft)", "date": "2026-11-23"},
    "game": {"name": "walker-rudy", "folder": "fall-2026/shuai-z/assignment-7/game", "revision": A7,
             "short_revision": "7620641", "tag": "a7", "engine": "4.7.2.stable.official.ed1daf0bf"},
    "honesty": {"live": LIVE_LABEL, "constructed": CONSTRUCTED, "generated": GENERATED,
                "rule": "past tense only for what exists and is shown; everything else is 'will' or 'designed'"},
    "audio_policy": ("narration only; the game's own audio is muted in every clip, so none of the ElevenLabs "
                     "sound effects is in the film"),
    "drafted_by": "Claude Code (Claude Opus 5.5), 2026-11-23, from my brief and GDD; I review every line",
    "tags": ["Walker Rudy", "Godot", "game design document", "final project pitch", "CSYE 7270"]},
    "beats": beats}

# Carry the measured audio forward (the show-tell skill: a sheet without audio_file and actual_duration_s
# makes `art run` refuse). The audio counts only if it was voiced from today's narration: finish_audio.py
# records the text each mp3 was made from in mp3/voiced.json, and a beat whose words changed since is
# reported as STALE and left without audio until it is voiced again.
voiced_path = PITCH / "mp3" / "voiced.json"
voiced = json.loads(voiced_path.read_text()) if voiced_path.exists() else {}
stale = []
for b in beats:
    mp3 = PITCH / "mp3" / f"beat-{b['beat_id']}.mp3"
    if not mp3.exists():
        continue
    if voiced.get(b["beat_id"]) != b["narration_text"]:
        stale.append(b["beat_id"])
        continue
    import subprocess
    secs = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0",
                                 str(mp3)], capture_output=True, text=True, check=True).stdout)
    b["audio_file"] = f"mp3/beat-{b['beat_id']}.mp3"
    b["actual_duration_s"] = round(secs, 2)
if stale:
    print(f"STALE audio (narration changed since it was voiced; voice again with --only): {' '.join(stale)}")

(PITCH / "beat_sheet.json").write_text(json.dumps(sheet, indent=2, ensure_ascii=False) + "\n")
total = sum(b["estimated_duration_s"] for b in beats) + 0.8 + 1.0
words = sum(len(b["narration_text"].split()) for b in beats)
measured = words / 3.42 + 0.8 + 1.0
print(f"{len(beats)} beats; {words} words; estimated {total:.0f} s ({total / 60:.1f} min) at 2.5 words/s, "
      f"{measured:.0f} s ({measured / 60:.1f} min) at A7's measured 3.42 words/s")

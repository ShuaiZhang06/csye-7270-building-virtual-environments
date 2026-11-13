# The motion reference: sources and frame counts

I chose to use openly licensed footage instead of filming myself. Claude Code found these three videos on Wikimedia Commons on 2026-11-12, and downloaded them at my word ("可以下载") the same day. Claude also extracted the frames and counted them. The counts below are Claude's reading of the frames. I checked them against the contact sheets on 2026-11-12 ("核对好了": checked).

The videos and their frames are not committed: they are third-party media, and only the measurements are needed here. Each video is identified by its SHA-256 (`logs/probe.log`).

## Sources

| Used for | Title | Author | Licence | Where | File used | SHA-256 |
|---|---|---|---|---|---|---|
| The swing | "IMG 8252" Hand-and-a-half sword (Bastard sword) exercises | Kuroczynski (Wikimedia Commons user), 2 September 2023 | CC BY-SA 4.0 | [Commons page](https://commons.wikimedia.org/wiki/File:%22IMG_8252%22_Hand-and-a-half_sword_(Bastard_sword)_exercises.webm) | Commons' 480p VP9 transcode, 270 × 480, 2,375,118 bytes | `b331e5ac…29f7` |
| The run, 3.0 m/s | S1 Video: "Video from the side-view showing a non-amputee sprinter at his slowest speed of 3.0 m/s." | Arellano C, McDermott W, Kram R, Grabowski A (2015), "Effect of Running Speed and Leg Prostheses on Mediolateral Foot Placement and Its Variability", PLOS ONE, DOI 10.1371/journal.pone.0115637 | CC BY 4.0 | [Commons page](https://commons.wikimedia.org/wiki/File:Effect-of-Running-Speed-and-Leg-Prostheses-on-Mediolateral-Foot-Placement-and-Its-Variability-pone.0115637.s003.ogv) | the original, 854 × 480, 3,802,552 bytes | `373b886e…83d5` |
| The run, 9.0 m/s | S3 Video, from the same study: the same runner at his maximum speed of 9.0 m/s | as above | CC BY 4.0 | [Commons page](https://commons.wikimedia.org/wiki/File:Effect-of-Running-Speed-and-Leg-Prostheses-on-Mediolateral-Foot-Placement-and-Its-Variability-pone.0115637.s005.ogv) | the original, 854 × 480, 5,105,159 bytes | `cfd07d80…f524` |

All three are 29.97 fps (30000/1001). ffprobe decoded 539, 299 and 295 frames (`logs/probe.log`).

## How the frames were counted

- **Extraction.** Every frame was extracted with `ffmpeg -start_number 0`, so a frame number here is its 0-based decode index: frame *n* is at *n* / 29.97 s.
- **The swing.** `tools/sheet.py` and `tools/crop_sheet.py` made numbered contact sheets, and the phases were read off them by eye.
- **The runs.** `tools/period.py` measured the period by self-similarity. For each lag *k*, it takes the mean absolute grey-level difference between frame *t* and frame *t + k* in the legs' crop, averaged over the steady part of each video (frames 12 onwards, after the camera has stopped zooming). A run repeats every stride, so the differences dip at the stride and at its multiples. Seen from the side, they also dip at half a stride, where the legs have swapped (`logs/period_run_3ms.log`, `logs/period_run_9ms.log`). A look at the 9.0 m/s feet, frames 100–129, was the visual check.

## The swing: one overhead cut, frames 315–340

He faces left and holds the sword in both hands. It is a hand-and-a-half sword cut, not a one-handed swing like Rudy's.

| Phase | Frames | Frames counted | Seconds | What the frames show |
|---|---|---|---|---|
| Wind-up: the backswing | 315 → 324 | 9 | 0.300 | The blade leaves its forward-up position (315), rises to vertical (320–321) and goes back over his shoulder, deepest at 324 |
| Wind-up: the hold | 324 → 327 | 3 | 0.100 | Cocked behind his head |
| Wind-up: the turn forward | 328 → 330 | 2 | 0.067 | Slowly back up to vertical over his head |
| **Wind-up, in all** | **315 → 330** | **15** | **0.500** | |
| **Strike** | **330 → 336** | **6** | **0.200** | From vertical overhead (330), through horizontal in front (about 334), to below horizontal (336). Heavy motion blur on 331–335 |
| **Follow-through** | **336 → 340** | **4** | **0.133** | The blade slows and settles pointing forward and down; still from 340 on |

Within the strike, the blade goes from vertical to horizontal in the first 4 of its 6 frames.

## The run

| Speed | Stride (one leg to the same leg) | Step (one foot's contact to the other's) | Steps per second | Check |
|---|---|---|---|---|
| 3.0 m/s | 22 frames, 0.734 s (the deepest dip, `period_run_3ms.log:22`) | 11 frames, 0.367 s (`:11`) | 2.72 | About 163 steps a minute, a normal running cadence at this speed |
| 9.0 m/s | about 14.7 frames, 0.49 s (dips at 15 and 29, `period_run_9ms.log:15`, `:29`) | about 7.4 frames, 0.246 s (dips at 7, 15, 22, 29, 37) | 4.1 | Contacts by eye at about frames 103/104, 110/111, 117/118, 124/125: every 7 frames |

Both cadences are what real runners do at these speeds. So the videos play in real time, not slowed down, and the counts are real times.

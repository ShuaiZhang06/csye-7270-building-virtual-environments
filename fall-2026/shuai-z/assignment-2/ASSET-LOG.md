# Asset log — walker-rudy

This log has one row per generation I kept or seriously considered. IDs match STORYBOARD.md and CHARACTER-SHEET.md. Each round's generation log quotes the prompts in full.

Files are kept as follows:
- full-size downloads stay in `_raw/`, which is not in git;
- accepted originals go to `generated/accepted/`;
- rejected outputs are kept as thumbnails in `generated/rejected/`;
- checks at game size go to `generated/checks/`, made with `design/tools/check_against_sheet.py`.

## Models and terms

| Model | Version | Where it ran | License / terms | Used for |
|---|---|---|---|---|
| Gemini app image generation, which the app reports as Nano Banana | The exact image-model version is not shown. The chat model was Gemini 3.8 Flash | Gemini app, hosted by Google, on my personal Google account | Google Terms of Service and the [Generative AI Additional Terms of Service](https://policies.google.com/terms/generative-ai). The page fetched on 2026-10-01 says it was last modified 2023-08-09. It forbids using the service to develop machine-learning models and requires following the Generative AI Prohibited Use Policy. It does not say who owns generated content | CHAR-REF-01 to CHAR-REF-07 |

## Log

| Asset ID | Model and version | Prompt and settings | Outcome | Edits | Where used |
|---|---|---|---|---|---|
| CHAR-REF-01 | Gemini app, Nano Banana | Turn 1: prompts v1 CHAR-REF, unchanged ([log](generated/logs/2026-10-01-gemini-CHAR-REF.md)). 16:9 requested; exported as a 1024×572 JPEG; seed not available | **Superseded.** Four views at one height, plain robe, as asked. I moved on to add patterns; reason not recorded. Same body as 04: about 3.4 heads tall, where the sheet says 2.5 | none | not used; thumbnail in `generated/rejected/CHAR-REF-01-03.png` |
| CHAR-REF-02 | same | Turn 2, edit of 01: "衣服上加一些白色、淡金色、黑色的花纹" [add some white, pale-gold and black patterns to the clothes] | **Rejected:** "too many patterns, too flashy" (my turn 3) | none | not used; thumbnail |
| CHAR-REF-03 | same | Turn 3, edit of 02: "花纹太多了，太浮夸了" [too many patterns; too flashy] | **Rejected:** "now there are no patterns at all" (my turn 4) | none | not used; thumbnail |
| CHAR-REF-04 | same | Turn 4, edit of 03: "现在又完全没花纹了，稍微加一点白色、淡金色、黑色的花纹" [no patterns at all now; add just a few white, pale-gold and black ones] | **Superseded.** The patterns were at the level I asked for, but at 160 px only the trim on the front opening still showed (check: `generated/checks/CHAR-REF-04-check.png`). I kept only the edge trim next (turn 5) | none | not used; thumbnail in `generated/rejected/CHAR-REF-04-06.png` |
| CHAR-REF-05 | same | Turn 5, edit of 04. This was Claude's suggested edit, with its proportions sentence removed by me ([log](generated/logs/2026-10-01-gemini-CHAR-REF-round2.md)): keep everything, keep only the thin light trim, remove the small motifs | **Rejected:** the motifs were gone, but the trim differed between the views (my turn 6) | none | not used; thumbnail |
| CHAR-REF-06 | same | Turn 6: "保持正面图的花纹不变，另外几张图的花纹都要跟正面图的花纹相对应" [keep the front view's patterns, and make the other views match it] | **Rejected:** the trim now matched, but the robe's hem was split in the middle two views (my turn 7) | none | not used; thumbnail |
| CHAR-REF-07 | same | Turn 7: "保持花纹不变，中间两张图的衣服尾端不要开叉" [keep the patterns; in the middle two views the hem should not be split]. Full-size original 2000×1116 JPEG | **Accepted.** The trim is the same in all four views and the hem is closed. I kept the proportions (about 3.4 heads), adopted by CHARACTER-SHEET.md revision 2. Check: `generated/checks/CHAR-REF-07-check.png` | none | `generated/accepted/CHAR-REF-07.jpg`, the reference for every pose of Rudy; it does not appear in the game itself |

# TYPECHECK.md — GATE T

Reel: `walker-rudy-final-pitch`  |  Checked: 2026-11-24T00:38  |  Overall: PASS  |  Beats checked: 34  |  FAILs: 0

Spec: `skills/make/kerning/reference/type-spec.md` §8.  Floor: 1.9% frame-height.  Contrast: 4.5:1 WCAG.  Kern threshold: 3.5× expected advance.  Wordy budget: 2 elements.

| beat | lane | polarity | worst finding | status | fix |
|------|------|----------|---------------|--------|-----|
| BIDEA | bookend | light | min-size §8.1: min text-run height 50px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B00 | manim | light | min-size §8.1: min text-run height 76px >= floor 41px | PASS | — |
| BDEFS | manim | light | min-size §8.1: min text-run height 69px >= floor 41px | PASS | — |
| B01 | evidence | — | no video | SKIP | — |
| B02 | evidence | — | no video | SKIP | — |
| B03 | manim | light | min-size §8.1: min text-run height 438px >= floor 41px | PASS | — |
| B04 | manim | light | min-size §8.1: min text-run height 960px >= floor 41px | PASS | — |
| B05 | manim | light | min-size §8.1: min text-run height 279px >= floor 41px | PASS | — |
| B06 | manim | light | min-size §8.1: min text-run height 62px >= floor 41px | PASS | — |
| B07 | evidence | — | no video | SKIP | — |
| B08 | manim | light | min-size §8.1: min text-run height 63px >= floor 41px | PASS | — |
| B09 | manim | light | min-size §8.1: min text-run height 989px >= floor 41px | PASS | — |
| B10 | manim | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| B11 | evidence | — | no video | SKIP | — |
| B12 | manim | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| B13 | manim | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| B14 | manim | light | min-size §8.1: min text-run height 41px >= floor 41px | PASS | — |
| B15 | manim | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| B16 | manim | light | min-size §8.1: min text-run height 51px >= floor 41px | PASS | — |
| B17 | manim | light | min-size §8.1: min text-run height 63px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B18 | manim | light | min-size §8.1: min text-run height 64px >= floor 41px | PASS | — |
| B19 | manim | light | min-size §8.1: min text-run height 441px >= floor 41px | PASS | — |
| B20 | manim | light | min-size §8.1: min text-run height 63px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B21 | manim | light | min-size §8.1: min text-run height 90px >= floor 41px | PASS | — |
| B22 | manim | light | min-size §8.1: min text-run height 41px >= floor 41px | PASS | — |
| B23 | manim | light | min-size §8.1: min text-run height 59px >= floor 41px | PASS | — |
| B24 | manim | light | min-size §8.1: min text-run height 51px >= floor 41px | PASS | — |
| B25 | manim | light | min-size §8.1: min text-run height 54px >= floor 41px | PASS | — |
| B26 | manim | light | min-size §8.1: min text-run height 52px >= floor 41px (individual-char fallback at 2×) | PASS | — |
| B27 | manim | light | min-size §8.1: min text-run height 56px >= floor 41px | PASS | — |
| B28 | evidence | — | no video | SKIP | — |
| B29 | manim | light | min-size §8.1: min text-run height 438px >= floor 41px | PASS | — |
| B30 | manim | light | min-size §8.1: min text-run height 50px >= floor 41px | PASS | — |
| BOUT | manim | light | min-size §8.1: min text-run height 96px >= floor 41px | PASS | — |

---

## Failures requiring action before cut

*None — GATE T PASS.*
---

## Check summary

| Check | Beats checked | FAILs |
|-------|---------------|-------|
| no-wordy-card §8.5 | 0 | 0 |
| min-size §8.1 | 29 | 0 |
| overflow §8.2 | 29 | 0 |
| contrast §8.3 | 29 | 0 |
| contrast-local §8.3b | 29 | 0 |
| bbox-overlap §8.6b | 29 | 0 |
| card-clip §8.13 | 29 | 0 |
| kerning §8.4 | 28 | 0 |
| redundancy §8.10 (advisory) | 0 | 0 (advisory — no exit effect) |

---

*GATE T: any FAIL blocks `./art run` and `./art final`. Fix the flagged beats and re-run `scripts/type_check.py` until green.*

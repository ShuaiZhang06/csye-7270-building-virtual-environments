# TYPECHECK.md — GATE T

Reel: `claude-liam-walker-rudy-animation`  |  Checked: 2026-11-17T19:25  |  Overall: PASS  |  Beats checked: 31  |  FAILs: 0

Spec: `skills/make/kerning/reference/type-spec.md` §8.  Floor: 1.9% frame-height.  Contrast: 4.5:1 WCAG.  Kern threshold: 3.5× expected advance.  Wordy budget: 2 elements.

| beat | lane | polarity | worst finding | status | fix |
|------|------|----------|---------------|--------|-----|
| B00 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| B01 | ? | light | min-size §8.1: min text-run height 97px >= floor 41px | PASS | — |
| B02 | ? | — | no video | SKIP | — |
| B03 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B04 | ? | — | no video | SKIP | — |
| B05 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B06 | ? | — | no video | SKIP | — |
| B07 | ? | — | no video | SKIP | — |
| B08 | ? | light | no-wordy-card §8.5: pull-quote (5 words ≤ 12) | PASS | — |
| B09 | ? | — | no video | SKIP | — |
| B10 | ? | — | no video | SKIP | — |
| B11 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B12 | ? | — | no video | SKIP | — |
| B13 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B14 | ? | — | no video | SKIP | — |
| B15 | ? | light | no-wordy-card §8.5: no prose payload found | PASS | — |
| B16 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B17 | ? | — | no video | SKIP | — |
| B18 | ? | — | no video | SKIP | — |
| B19 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B20 | ? | — | no video | SKIP | — |
| B21 | ? | light | no-wordy-card §8.5: pull-quote (3 words ≤ 12) | PASS | — |
| B22 | ? | — | no video | SKIP | — |
| B23 | ? | — | no video | SKIP | — |
| B24 | ? | — | no video | SKIP | — |
| B25 | ? | — | no video | SKIP | — |
| BVD1 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| BVD2 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| BVD3 | ? | light | min-size §8.1: hand-drawn pattern (ClaudeVerdictArtifact) — §8.1 hachure/crossbar fragment… | PASS | — |
| BHTF | ? | light | min-size §8.1: hand-drawn pattern (ClaudeComposerAsk) — §8.1 hachure/crossbar fragments ar… | PASS | — |
| BOUT | ? | dark | min-size §8.1: min text-run height 44px >= floor 41px | PASS | — |

---

## Failures requiring action before cut

*None — GATE T PASS.*
---

## Check summary

| Check | Beats checked | FAILs |
|-------|---------------|-------|
| no-wordy-card §8.5 | 9 | 0 |
| min-size §8.1 | 16 | 0 |
| overflow §8.2 | 16 | 0 |
| contrast §8.3 | 16 | 0 |
| contrast-local §8.3b | 16 | 0 |
| bbox-overlap §8.6b | 16 | 0 |
| card-clip §8.13 | 16 | 0 |
| kerning §8.4 | 0 | 0 |
| redundancy §8.10 (advisory) | 3 | 0 (advisory — no exit effect) |

---

*GATE T: any FAIL blocks `./art run` and `./art final`. Fix the flagged beats and re-run `scripts/type_check.py` until green.*

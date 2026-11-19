"""Compare a windowed Movie Maker log with its headless dry run: every frame line and every tick line must match."""
import sys
def lines(path, prefixes):
    return [l.rstrip("\n") for l in open(path, errors="replace") if l.startswith(prefixes)]
dry, win = sys.argv[1], sys.argv[2]
for prefixes, name in ((("frame ",), "frame"), (("tick ", "take "), "tick/take")):
    a, b = lines(dry, prefixes), lines(win, prefixes)
    diffs = [(i, x, y) for i, (x, y) in enumerate(zip(a, b)) if x != y]
    print(f"{name}: dry {len(a)}, window {len(b)}, differing {len(diffs)}")
    for i, x, y in diffs[:5]:
        print("  dry:", x); print("  win:", y)

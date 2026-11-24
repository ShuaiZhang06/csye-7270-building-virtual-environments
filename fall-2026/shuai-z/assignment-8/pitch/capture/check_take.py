"""check_take.py AVI WINDOW_LOG DRY_LOG — checks one Movie Maker take of the Assignment 8 pitch film.

Adapted by Claude Code from Assignment 7's capture/frozen.py and capture/compare.py. A take passes only if:
1. the AVI has one video packet per "frame" line in its log;
2. the driver's window guard printed exactly "draw 0 true" (the window could draw from the first frame to the last);
3. no MJPEG packet repeats the one before it, except where the log says nothing on screen changed (on macOS a
   covered window is not drawn, and Movie Maker then writes the last image again: a repeat anywhere else means
   the window did not draw, and the take is void);
4. every "frame", "event" and "step" line equals its headless dry run's, so the windowed take played the same
   game, tick for tick, as the run whose log was read before it.
"""
import re
import subprocess
import sys

avi, win_log, dry_log = sys.argv[1], sys.argv[2], sys.argv[3]


def lines(path, prefixes):
    return [l.rstrip("\n") for l in open(path, errors="replace") if l.startswith(prefixes)]


md5 = [l.split(",")[-1].strip() for l in subprocess.run(
    ["ffmpeg", "-v", "error", "-i", avi, "-map", "0:v", "-c", "copy", "-f", "framemd5", "-"],
    capture_output=True, text=True, check=True).stdout.splitlines() if l and not l.startswith("#")]
state = {}
for l in lines(win_log, ("frame ",)):
    m = re.match(r"^frame (\d+) (.*)$", l)
    state[int(m.group(1))] = m.group(2)
draws = [l.strip() for l in lines(win_log, ("draw ",))]
repeats = [i for i in range(1, len(md5)) if md5[i] == md5[i - 1]]
bad = [i for i in repeats if state.get(i) != state.get(i - 1)]
failures = []
if len(md5) != len(state):
    failures.append(f"{len(md5)} video packets but {len(state)} frame lines")
if draws != ["draw 0 true"]:
    failures.append(f"draw lines {draws}")
if bad:
    failures.append(f"{len(bad)} repeated images where the log says the picture changed: {bad[:10]}")
def runs(idx):
    out, start = [], None
    for k, i in enumerate(idx):
        if start is None: start = i
        if k + 1 == len(idx) or idx[k + 1] != i + 1:
            out.append(f"{start}-{i}" if i > start else str(start)); start = None
    return out


print(f"{avi.split('/')[-1]}: {len(md5)} packets, {len(state)} frame lines, {len(repeats)} repeats "
      f"(all where nothing changed: {not bad}), draw lines {draws}")
if repeats:
    print(f"  repeated frames: {', '.join(runs(repeats))}")
for prefixes, name in ((("frame ",), "frame"), (("event ",), "event"), (("step:",), "step")):
    a, b = lines(dry_log, prefixes), lines(win_log, prefixes)
    diffs = [(i, x, y) for i, (x, y) in enumerate(zip(a, b)) if x != y]
    print(f"  {name} lines: dry run {len(a)}, window {len(b)}, differing {len(diffs)}")
    if len(a) != len(b) or diffs:
        failures.append(f"{name} lines differ from the dry run")
        for i, x, y in diffs[:3]:
            print("    dry:   ", x)
            print("    window:", y)
for f in failures:
    print("  FAIL:", f)
print("  PASS" if not failures else "  VOID")
sys.exit(1 if failures else 0)

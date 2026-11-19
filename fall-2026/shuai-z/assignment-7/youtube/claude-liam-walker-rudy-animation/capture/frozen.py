"""Frozen-frame check. Movie Maker writes one MJPEG packet per frame; two identical packets in a row are two identical images.
That is allowed only where the driver's log says nothing on screen changed (Rudy, the clip, goblin B); anywhere else the
window did not draw and the take is void."""
import re, subprocess, sys
avi, log = sys.argv[1], sys.argv[2]
md5 = [l.split(",")[-1].strip() for l in subprocess.run(["ffmpeg", "-v", "error", "-i", avi, "-map", "0:v", "-c", "copy", "-f", "framemd5", "-"],
       capture_output=True, text=True, check=True).stdout.splitlines() if l and not l.startswith("#")]
state = {}
for l in open(log, errors="replace"):
    m = re.match(r"^frame (\d+) (.*)$", l)
    if m: state[int(m.group(1))] = re.sub(r" pos [\d.]+", "", m.group(2))  # the clip position alone may advance on a held one-key clip
draws = [l.strip() for l in open(log, errors="replace") if l.startswith("draw ")]
bad = [i for i in range(1, len(md5)) if md5[i] == md5[i - 1] and state.get(i) != state.get(i - 1)]
same = sum(1 for i in range(1, len(md5)) if md5[i] == md5[i - 1])
print(f"{avi.split('/')[-1]}: {len(md5)} frames, log {len(state)} frames, {same} repeats, {len(bad)} repeats where the log says the picture changed {bad[:8]}; draw lines {draws}")
sys.exit(1 if bad or len(md5) != len(state) or draws != ["draw 0 true"] else 0)

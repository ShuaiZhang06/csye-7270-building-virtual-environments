#!/usr/bin/env bash
# mutate.sh <C0|M1|M2|M3|M4> <output folder>: one mutation in a fresh git
# worktree at HEAD, the read-back run through the wrapper, then the worktree
# thrown away. Outputs go to the output folder, never into the main working
# tree. The run of 2026-11-13 used this script with the repository and output
# paths written out; this copy finds the repository from its own location.
set -u
ID=$1
OUT=${2:?usage: mutate.sh <C0|M1|M2|M3|M4> <output folder>}
REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
WT="$(dirname "$REPO")/a7-mutate"
mkdir -p "$OUT"
LIB=game/animations/rudy_animations.tres

if [ ! -d "$WT" ]; then
	git -C "$REPO" worktree add --no-checkout --detach "$WT" HEAD > /dev/null 2>&1 || { echo "worktree add failed"; exit 2; }
	git -C "$WT" sparse-checkout set --cone fall-2026/shuai-z/assignment-7 > /dev/null 2>&1
	git -C "$WT" reset -q --hard HEAD
fi
cd "$WT/fall-2026/shuai-z/assignment-7" || exit 2
{
	echo "mutation $ID, worktree $(basename "$WT") at $(git rev-parse --short HEAD), $(date '+%Y-%m-%d %H:%M:%S %Z')"
	godot --headless --path game --import > /dev/null 2>&1
	echo "import (fresh worktree): exit $?"
	case $ID in
	C0) echo "control: no change" ;;
	M1) python3 -I - "$LIB" <<'EOF'
import sys
p=sys.argv[1]; s=open(p).read()
a='tracks/2/path = NodePath("SlashRig/Lean/Grip:rotation_degrees")'
assert s.count(a)==1
open(p,'w').write(s.replace(a,'tracks/2/path = NodePath("SlashRig/Lean/Grip:rotation_degree")'))
EOF
	echo "M1: slash track 2's subname rotation_degrees -> rotation_degree, in the clip only" ;;
	M2) python3 -I - "$LIB" <<'EOF'
import sys
p=sys.argv[1]; s=open(p).read()
a='resource_name = "run"\nlength = 0.25\nloop_mode = 1\n'
assert s.count(a)==1
open(p,'w').write(s.replace(a,'resource_name = "run"\nlength = 0.25\nloop_mode = 0\n'))
EOF
	echo "M2: run's loop_mode 1 (LOOP_LINEAR) -> 0 (LOOP_NONE)" ;;
	M3) python3 -I - "$LIB" <<'EOF'
import sys
p=sys.argv[1]; s=open(p).read()
i=s.index('resource_name = "run"\n'); j=s.index('[sub_resource', i)
blk=s[i:j]; a='"values": [1, 2]'
assert blk.count(a)==1
open(p,'w').write(s[:i]+blk.replace(a,'"values": [16, 2]')+s[j:])
EOF
	echo "M3: run's first frame key 1 -> 16 (hframes * vframes)" ;;
	M4) rm -rf game/.godot
		echo "M4: game/.godot deleted: $( [ -d game/.godot ] && echo no || echo yes )"
		godot --headless --path game --import > /dev/null 2>&1
		echo "import from the empty cache: exit $?" ;;
	esac
	echo "--- git diff in the worktree"
	git diff --stat
	git diff -U1 | sed -n '5,40p'
	echo "--- scripts/run-test.sh test_rudy_clips.tscn 60"
	scripts/run-test.sh test_rudy_clips.tscn 60 > /dev/null 2>&1
	st=$?
	echo "exit $st"
	grep -E '^FAIL|^RESULT' logs/test_rudy_clips_60fps.log
} > "$OUT/$ID.txt" 2>&1
cp logs/test_rudy_clips_60fps.log "$OUT/$ID-test_rudy_clips_60fps.log"
cd "$REPO" && git worktree remove --force "$WT" && git worktree prune
echo "$ID done: $(grep -E '^exit|^RESULT' "$OUT/$ID.txt" | tr '\n' ' ')"

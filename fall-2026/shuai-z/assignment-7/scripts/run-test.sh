#!/usr/bin/env bash
# scripts/run-test.sh <test-file> <fps|realtime> [timeout-seconds]
#
# The course's Assignment 6 wrapper as assignment-6/ adapted it, carried into
# Assignment 7. The four changes from assignment-6 stay:
#   - The project is game/ (the 2D game, from Assignment 2), so it runs
#     --path game; the course's version runs --path godot.
#   - A .tscn test runs as the scene, as the game's checks.tscn always has (its
#     script extends Node, so --script cannot run it); a .gd test still runs
#     with --script. The log is named after the file without its extension.
#   - Godot is $GODOT if set, else godot on PATH, else the macOS app's binary.
#   - It runs from this folder wherever it is called from, so the project path
#     resolves and the logs land in its logs/.
# New in Assignment 7: a resource that fails to load fails the run. Godot 4.7.2
# loads a scene whose texture or sub-scene is missing, instances it and exits
# 0, saying so only in the log (evidence/load-error-probe/). So besides SHADER
# ERROR and SCRIPT ERROR, the run fails on these lines from that probe:
#   Cannot open file          a file that does not exist
#   Failed loading resource   any load that returned null
#   Resource file not found   a missing ext_resource or typed load
#   Parse Error               a broken .tres/.tscn, or an ext_resource that
#                             names a missing file (the scene still loads)
#   Error loading resource    ResourceLoader.load() of a missing file
#   Failed to load script     a script that does not compile
#   couldn't resolve track    an animation track naming a node that does not
#                             exist (a WARNING; a missing property prints
#                             nothing, so the read-back test must check that)
# When one of these fails the run, the wrapper prints the lines it matched.
# Unchanged from the course: the realtime mode (no --fixed-fps, for tests that
# wait on audio), the optional timeout (120 s by default; status 124 means the
# test hung), the log name logs/<test>_<fps>fps.log or logs/<test>_realtime.log,
# and that exit code 0 does not mean no errors.
set -o pipefail
cd "$(dirname "$0")/.." || exit 2
if [ $# -lt 2 ] || [ $# -gt 3 ] || [ ! -f "game/tests/$1" ]; then
	echo "usage: scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]" >&2
	exit 2
fi
godot=${GODOT:-$(command -v godot || echo /Applications/Godot.app/Contents/MacOS/Godot)}
if [ "$2" = "realtime" ]; then
	fps_args=(); tag="realtime"
else
	fps_args=(--fixed-fps "$2"); tag="${2}fps"
fi
if [[ $1 == *.tscn ]]; then
	run_args=("res://tests/$1")
else
	run_args=(--script "res://tests/$1")
fi
mkdir -p logs
log="logs/$(basename "${1%.*}")_${tag}.log"
timeout "${3:-120}" "$godot" --headless "${fps_args[@]}" --path game "${run_args[@]}" 2>&1 | tee "$log"
status=$?
errors="SHADER ERROR|SCRIPT ERROR|Cannot open file|Failed loading resource|Resource file not found|Parse Error|Error loading resource|Failed to load script|couldn't resolve track"
if grep -qE "$errors" "$log"; then
	echo "run-test.sh: FAILED on an error line in $log:" >&2
	grep -nE "$errors" "$log" >&2
	status=1
fi
exit $status

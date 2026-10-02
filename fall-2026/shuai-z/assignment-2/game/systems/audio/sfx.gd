extends Node
## The one entry point for sound effects (CHANGE-BRIEF.md, event-to-sound map).
## Gameplay calls play(id) right after the code that represents the event has
## changed the game state. Nothing reads a sound back, so a missing or muted
## sound changes nothing.
##
## Until the audio step this only counts plays per ID; the checks compare the
## counts with the events that actually happened.

var counts: Dictionary[StringName, int] = {}


func play(id: StringName) -> void:
	counts[id] = count(id) + 1


func count(id: StringName) -> int:
	return counts.get(id, 0)


func reset_counts() -> void:
	counts.clear()


## "jump 2  stomp 1", for the debug line.
func summary() -> String:
	if counts.is_empty():
		return "none yet"
	var parts: PackedStringArray = []
	for id: StringName in counts:
		parts.append("%s %d" % [id, counts[id]])
	return "  ".join(parts)

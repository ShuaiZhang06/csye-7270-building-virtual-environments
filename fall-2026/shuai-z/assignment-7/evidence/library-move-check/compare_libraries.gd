extends SceneTree
# Compares two clip libraries clip by clip, track by track, key by key.
func _init() -> void:
	var a: AnimationLibrary = ResourceLoader.load(OS.get_cmdline_user_args()[0], "", ResourceLoader.CACHE_MODE_IGNORE)
	var b: AnimationLibrary = ResourceLoader.load(OS.get_cmdline_user_args()[1], "", ResourceLoader.CACHE_MODE_IGNORE)
	var diffs := 0
	var keys := 0
	var na := a.get_animation_list()
	var nb := b.get_animation_list()
	na.sort(); nb.sort()
	if na != nb:
		print("DIFF clip names %s vs %s" % [na, nb]); diffs += 1
	for n in na:
		var x := a.get_animation(n)
		var y := b.get_animation(n)
		for prop in ["length", "loop_mode", "step"]:
			if x.get(prop) != y.get(prop):
				print("DIFF %s %s %s vs %s" % [n, prop, x.get(prop), y.get(prop)]); diffs += 1
		if x.get_track_count() != y.get_track_count():
			print("DIFF %s track count" % n); diffs += 1; continue
		for t in x.get_track_count():
			if x.track_get_path(t) != y.track_get_path(t) or x.track_get_type(t) != y.track_get_type(t) \
					or x.track_get_interpolation_type(t) != y.track_get_interpolation_type(t) \
					or x.value_track_get_update_mode(t) != y.value_track_get_update_mode(t) \
					or x.track_get_key_count(t) != y.track_get_key_count(t):
				print("DIFF %s track %d header" % [n, t]); diffs += 1; continue
			for k in x.track_get_key_count(t):
				keys += 1
				if x.track_get_key_time(t, k) != y.track_get_key_time(t, k) \
						or x.track_get_key_value(t, k) != y.track_get_key_value(t, k) \
						or x.track_get_key_transition(t, k) != y.track_get_key_transition(t, k):
					print("DIFF %s track %d key %d" % [n, t, k]); diffs += 1
	print("compared %d clips, %d keys: %d differences" % [na.size(), keys, diffs])
	quit(0)

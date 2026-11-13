extends SceneTree
static func track_problems(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var root := player.get_node(player.root_node)
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			var path := clip.track_get_path(t)
			var node := root.get_node_or_null(NodePath(path.get_concatenated_names()))
			if node == null:
				problems.append("%s track %d: no node at %s" % [clip_name, t, path])
				continue
			if path.get_subname_count() == 0:
				continue
			var sub := path.get_subname(0)
			match clip.track_get_type(t):
				Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D:
					var skeleton := node as Skeleton3D
					if skeleton == null or skeleton.find_bone(sub) == -1:
						problems.append("%s track %d: no bone %s on %s" % [clip_name, t, sub, node.name])
				Animation.TYPE_BLEND_SHAPE:
					var mesh := node as MeshInstance3D
					if mesh == null or mesh.find_blend_shape_by_name(sub) == -1:
						problems.append("%s track %d: no blend shape %s on %s" % [clip_name, t, sub, node.name])
				_:
					if not (sub in node):
						problems.append("%s track %d: %s has no property %s" % [clip_name, t, node.name, sub])
	return problems
func _init() -> void:
	var a3: Animation = load("res://tests/probe/g3/loop_godot3.tres")
	var a4: Animation = load("res://tests/probe/g3/loop_godot4.tres")
	print("G3 'loop = true' -> loop_mode ", a3.loop_mode, " ; G4 'loop_mode = 1' -> loop_mode ", a4.loop_mode, " (0 none, 1 linear, 2 pingpong)")
	var ps: PackedScene = load("res://tests/probe/g3/player_godot3.tscn")
	var root := ps.instantiate(); get_root().add_child(root)
	var ap: AnimationPlayer = root.get_node("AP")
	print("G3 'playback_speed = 2.0' -> speed_scale ", ap.speed_scale)
	# track_problems on a clip with a good track, a missing node and a missing property
	var spr := Sprite2D.new(); spr.name = "Sprite"; root.add_child(spr)
	var clip := Animation.new()
	for p in ["Sprite:frame", "Nobody:frame", "Sprite:no_such_prop", "Sprite:rotation_degrees"]:
		var t := clip.add_track(Animation.TYPE_VALUE); clip.track_set_path(t, p); clip.track_insert_key(t, 0.0, 0)
	var lib := AnimationLibrary.new(); lib.add_animation("probe", clip); ap.add_animation_library("", lib)
	print("root_node ", ap.root_node)
	for p in track_problems(ap): print("PROBLEM ", p)
	quit(0)

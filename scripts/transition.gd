extends CanvasLayer

@onready var rect = $ColorRect

func fade_to(scene_path: String):
	var tween = create_tween()
	tween.tween_property(rect, "modulate", Color(1, 1, 1, 1), 0.5)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
	)

func fade_in():
	rect.modulate = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_property(rect, "modulate", Color(1, 1, 1, 0), 0.5)

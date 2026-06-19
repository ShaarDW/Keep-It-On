extends Control

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		get_tree().change_scene_to_file("res://escenas/main.tscn")

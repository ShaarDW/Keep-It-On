extends Control

@onready var audio = $AudioStreamPlayer

func _ready():
	audio.play()  # ← dentro de _ready

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		audio.stop()  # ← frenar antes de cambiar de escena
		get_tree().change_scene_to_file("res://escenas/main.tscn")

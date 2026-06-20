extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		button_down.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

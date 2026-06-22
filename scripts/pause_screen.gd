extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_touchscreen_button_pressed() -> void:
	set_visible(false)

func _on_touch_screen_button_pressed() -> void:
	set_visible(true)

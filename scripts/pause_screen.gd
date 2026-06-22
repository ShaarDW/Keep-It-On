extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_texture_button_button_down() -> void:
	set_visible(true)

func _on_resume_button_button_down() -> void:
	set_visible(false)

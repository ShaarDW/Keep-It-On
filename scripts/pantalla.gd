extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_toggled(toggled_on: bool) -> void:
	set_visible(toggled_on)

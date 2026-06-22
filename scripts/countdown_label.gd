extends Label

var time_left = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)
	set_text("3")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_resume_button_button_down() -> void:
	time_left = 3
	set_text(str(time_left))
	set_visible(true)

func _on_countdown_label_timer_timeout() -> void:
	_countdown()
	pass # Replace with function body.

func _countdown() -> void:
	if time_left > 0:
		set_text(str(time_left))
		$"countdown label timer".start()
		time_left -= 1
	else:
		set_visible(false)
		time_left = 3
		set_text(str(time_left))

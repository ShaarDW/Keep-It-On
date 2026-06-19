extends Control
@onready var score_label = $ScoreLabel
func _ready():
	pass

func setup(score: int, highscore: int):
	animate_score(score)
	$HighscoreLabel.text = "BEST: " + "%07d" % highscore

func animate_score(final_score: int):
	var final_text = "%07d" % final_score
	var current_value := 0
	
	var tween = create_tween()
	tween.tween_method(func(value: int):
		score_label.text = "Score: " + ("%07d" % value)
	, 0, final_score, 1.0)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
func play_go_animation():
	var tween = create_tween()
	
	# Apagamos todo
	tween.tween_property($Title, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($ScoreLabel, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($HighscoreLabel, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($Area2D/Label, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($Area2D2/Label2, "modulate", Color(0, 0, 0, 0), 0.5)
	
	# Aparecen G y O
	tween.tween_property($GoG, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.parallel().tween_property($GoO, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.parallel().tween_property($Gop, "modulate", Color(1, 1, 1, 1), 0.3)
	
	tween.tween_interval(0.6)
	
	# Cambiamos de escena
	tween.tween_callback(func():
		get_tree().paused = false
		queue_free()
		get_tree().change_scene_to_file("res://escenas/main.tscn")
	)
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		var touch_pos = event.position
		
		if touch_pos.distance_to($Area2D.global_position) < 100:
			play_go_animation()
		elif touch_pos.distance_to($Area2D2.global_position) < 100:
			get_tree().paused = false
			queue_free()
			get_tree().change_scene_to_file("res://escenas/main_menu.tscn")

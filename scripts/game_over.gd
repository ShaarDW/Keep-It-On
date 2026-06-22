extends Node2D

@onready var player = $Player
@onready var door_retry = $Walls/DoorRetry
@onready var door_menu = $Walls/DoorMenu
@onready var arrows_retry = $ArrowsRetry
@onready var arrows_menu = $ArrowsMenu
@onready var retry_label = $RetryLabel
@onready var menu_label = $MenuLabel

var arrow_timer := 0.0
var arrow_interval := 0.30
var current_arrow_retry := 0
var current_arrow_menu := 0

func _ready():
	Transition.fade_in()
	door_retry.body_entered.connect(_on_door_retry)
	door_menu.body_entered.connect(_on_door_menu)
	player.dim_duration = 99999999999999999.0
	player.clamp_enabled = false
	player.trail_points.clear()
	setup(GameData.final_score, GameData.highscore)

func _process(delta):
	arrow_timer += delta
	if arrow_timer >= arrow_interval:
		arrow_timer = 0.0
		animate_arrows()

func setup(score: int, highscore: int):
	$ScoreLabel.text = "Score: " + "%07d" % score
	$HighscoreLabel.text = "Best: " + "%07d" % highscore

func _on_door_retry(body):
	print("door retry tocada por: ", body.name)
	if body.is_in_group("player"):
		play_go_animation()

func _on_door_menu(body):
	print("door menu tocada por: ", body.name)
	if body.is_in_group("player"):
		Transition.fade_to("res://escenas/main_menu.tscn")

func play_go_animation():
	var tween = create_tween()
	tween.tween_property($Title, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($ScoreLabel, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.parallel().tween_property($HighscoreLabel, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.tween_property($GoG, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.parallel().tween_property($GoO, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.parallel().tween_property($Gop, "modulate", Color(1, 1, 1, 1), 0.3)
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		Transition.fade_to("res://escenas/main.tscn")
)
func animate_arrows():
	var total_retry = arrows_retry.get_child_count()
	var total_menu = arrows_menu.get_child_count()
	
	# Retry arrows
	if current_arrow_retry < total_retry:
		for i in range(total_retry):
			arrows_retry.get_child(i).modulate = Color(1, 1, 1, 0.2)
		arrows_retry.get_child(current_arrow_retry).modulate = Color(1, 1, 1, 1)
	else:
		for i in range(total_retry):
			arrows_retry.get_child(i).modulate = Color(1, 1, 1, 1)
	current_arrow_retry = (current_arrow_retry + 1) % (total_retry + 1)
	
	# Menu arrows
	if current_arrow_menu < total_menu:
		for i in range(total_menu):
			arrows_menu.get_child(i).modulate = Color(1, 1, 1, 0.2)
		arrows_menu.get_child(current_arrow_menu).modulate = Color(1, 1, 1, 1)

	else:
		for i in range(total_menu):
			arrows_menu.get_child(i).modulate = Color(1, 1, 1, 1)
	current_arrow_menu = (current_arrow_menu + 1) % (total_menu + 1)

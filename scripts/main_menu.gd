extends Node2D
@onready var title1 = $TitleLayer1
@onready var title2 = $TitleLayer2
@onready var title3 = $TitleLayer3
var origin1: Vector2
var origin2: Vector2
var origin3: Vector2
@onready var player = $Player
@onready var door_start = $Walls/DoorStart
@onready var arrows_right = $ArrowsRight
var arrow_timer := 0.0
var arrow_interval := 0.30
var current_arrow := 0
@onready var start_label = $StartLayer1
@onready var start2 = $StartLayer2
var start_origin1: Vector2
var start_origin2: Vector2
var start_blink_timer := 0.0
var start_blink_speed := 0.3
var start_origin: Vector2

@onready var audio = $AudioStreamPlayer

func _ready():
	audio.play()  # ← dentro de _ready

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		audio.stop()  # ← frenar antes de cambiar de escena
		get_tree().change_scene_to_file("res://escenas/main.tscn")



	Transition.fade_in()
	door_start.body_entered.connect(_on_door_start_entered)
	player.dim_duration = 99999999999999.0
	player.clamp_enabled = false
	origin1 = title1.position
	origin2 = title2.position
	origin3 = title3.position

func _on_door_start_entered(body):
	if body.is_in_group("player"):
		Transition.fade_to("res://escenas/main.tscn")

func _process(delta):
	var g: Vector2
	if OS.has_feature("mobile"):
		var acc = Input.get_accelerometer()
		g = Vector2(acc.x, -acc.y)
	else:
		g = Vector2.ZERO
	
	title1.position = title1.position.lerp(origin1 + g * 30.0, 5.0 * delta)
	title2.position = title2.position.lerp(origin2 + g * 15.0, 5.0 * delta)
	title3.position = title3.position.lerp(origin3 + g * 5.0, 5.0 * delta)
	arrow_timer += delta
	if arrow_timer >= arrow_interval:
		arrow_timer = 0.0
		animate_arrows()

func animate_arrows():
	var total = arrows_right.get_child_count()
	
	if current_arrow < total:
		# Modo secuencial: una flecha a la vez
		for i in range(total):
			arrows_right.get_child(i).modulate = Color(1, 1, 1, 0.2)
		arrows_right.get_child(current_arrow).modulate = Color(1, 1, 1, 1)
	else:
		# Todas las flechas + START juntos
		for i in range(total):
			arrows_right.get_child(i).modulate = Color(1, 1, 1, 1)
	
	current_arrow = (current_arrow + 1) % (total + 1)

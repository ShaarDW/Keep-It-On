extends Area2D

@onready var light = $PointLight2D
@onready var sprite = $Sprite2D
var spawn_pos: Vector2
var move_radius := 40.0
var velocity := Vector2.ZERO
var target_offset := Vector2.ZERO
var move_change_timer := 0.0
var blink_speed := 0.5
var blink_timer := 0.0
var is_lit := true

func _ready():
	add_to_group("collectibles")
	body_entered.connect(_on_body_entered)
	call_deferred("_init_position")
	blink_timer = randf_range(0, 3.0)

func _init_position():
	spawn_pos = global_position
	pick_new_target()

func _process(delta):
	move_change_timer += delta
	if move_change_timer >= 2.0:
		move_change_timer = 0.0
		pick_new_target()
	
	var current_offset = global_position - spawn_pos
	var new_offset = current_offset.lerp(target_offset, 1.0 * delta)
	global_position = spawn_pos + new_offset
	
	blink_timer += delta * blink_speed
	
	var t = (sin(blink_timer) + 1.0) / 2.0  # entre 0 y 1
	light.energy = lerp(0.0, 4.0, t)
	sprite.modulate = Color(lerp(0.2, 1.0, t), lerp(0.2, 1.0, t), lerp(0.2, 1.0, t), 1.0)

func pick_new_target():
	var angle = randf_range(0, TAU)
	var dist = randf_range(0, move_radius)
	target_offset = Vector2(cos(angle), sin(angle)) * dist

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.recharge()
		var main = get_tree().get_first_node_in_group("main")
		if main:
			main.add_score(10)
		queue_free()

extends RigidBody2D

var speed := 50.0
var player: Node2D = null
@onready var death_particles = $DeathParticles
var score_value := 10

func _ready():
	add_to_group("enemies")
	lock_rotation = false
	contact_monitor = true
	max_contacts_reported = 1
	await get_tree().process_frame
	if not is_inside_tree():
		return
	player = get_tree().get_first_node_in_group("player")
	

func _physics_process(delta):
	if not player or player.is_dead:
		return
	
	# Apunta la punta hacia el jugador
	var target_angle = (player.global_position - global_position).angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_angle, 5.0 * delta)
	
	# Avanza hacia el jugador
	var direction = (player.global_position - global_position).normalized()
	linear_velocity = direction * speed


func setup(spawn_pos: Vector2):
	call_deferred("set_global_position", spawn_pos)

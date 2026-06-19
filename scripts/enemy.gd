extends RigidBody2D

# Tipos de enemigo: [tamaño, velocidad]
var speed = 150.0
var enemy_types := {
	"small":  {"scale": 0.6, "speed": 400.0, "score": 15},
	"medium": {"scale": 1.0, "speed": 250.0, "score": 10},
	"large":  {"scale": 1.5, "speed": 120.0, "score": 5},
}

var score_value := 10
@onready var death_particles = $DeathParticles
var rotation_step := deg_to_rad(30)
var rotation_step_interval := 0.05 
var rotation_timer := 0.0

func _ready():
	add_to_group("enemies")
	lock_rotation = false
	contact_monitor = true
	max_contacts_reported = 1

		
func setup(spawn_pos: Vector2, type: String = ""):
	global_position = spawn_pos
	
	var chosen_type: String
	if type != "" and enemy_types.has(type):
		chosen_type = type
	else:
		var keys = enemy_types.keys()
		chosen_type = keys[randi() % keys.size()]
	
	var data = enemy_types[chosen_type]
	$Visual.scale = Vector2(data["scale"], data["scale"])
	$CollisionPolygon2D.scale = Vector2(data["scale"], data["scale"])
	speed = data["speed"]
	score_value = data["score"]
	
	var screen_size = get_viewport_rect().size
	var target = Vector2(
		randf_range(screen_size.x * 0.05, screen_size.x * 0.95),
		randf_range(screen_size.y * 0.05, screen_size.y * 0.95)
	)
	var direction = (target - spawn_pos).normalized()
	linear_velocity = direction * speed
	angular_velocity = 10.0

func _physics_process(delta):
	angular_velocity = 0.0  
	
	rotation_timer += delta
	if rotation_timer >= rotation_step_interval:
		rotation_timer = 0.0
		rotation += rotation_step
		# Mantener velocidad constante
	if linear_velocity.length() < speed * 0.9:
		linear_velocity = linear_velocity.normalized() * speed

func _process(_delta):
	# Destrucción al salir de pantalla
	var screen_size = get_viewport_rect().size
	if global_position.x < -100 or global_position.x > screen_size.x + 100:
		queue_free()
	if global_position.y < -100 or global_position.y > screen_size.y + 100:
		queue_free()

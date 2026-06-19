extends CharacterBody2D

var speed := 300.0
var max_speed := 700.0
var dim_timer := 0.0
var dim_duration := 15.0  # segundos hasta apagarse completamente
var max_light_energy := 25.0  # cambiá este valor a gusto
var is_dead := false
var damage_cooldown := false
var powerup_active := false
@onready var trail = get_tree().get_root().get_node("Main/Trail")
@onready var light = $PointLight2D
@onready var shockwave = $ShockWave
@onready var powerup_indicator = $PowerupIndicator
@onready var hitbox = $HitBox
var trail_points := []
var max_trail_points := 15
var trail_fade_speed := 3.0
var powerup_timer := 0.0
var powerup_duration := 8.0
var shadow_timer := 0.0
var shadow_interval := 0.10  # cada cuánto crea una sombra
signal died

func _ready():
	add_to_group("player")
	light.energy = max_light_energy
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		if powerup_active:
			var particles = body.get_node("DeathParticles")
			if particles:
				particles.reparent(get_tree().get_root())
				particles.emitting = true
			get_tree().get_first_node_in_group("main").screen_shake(8.0, 0.2)
			
			var main = get_tree().get_first_node_in_group("main")
			if main:
				main.add_score(body.score_value)
			
			body.queue_free()
		else:
			take_damage()
			body.queue_free()

func _physics_process(delta):
	if is_dead:
		return
	
	var direction = get_gravity_input()
	
	velocity = velocity.lerp(direction * speed, 2.0 * delta)
	velocity = velocity.limit_length(max_speed)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Rebote al chocar con pared
		velocity = velocity.bounce(collision.get_normal()) * 1
	
	clamp_to_screen()
	
	if not powerup_active:
		dim_timer += delta
		update_brightness()
		if dim_timer >= dim_duration and not is_dead:
			lose_life()
	
	if powerup_active:
		powerup_timer += delta
		var ratio = 1.0 - (powerup_timer / powerup_duration)
		powerup_indicator.material.set_shader_parameter("progress", ratio)
		$Sprite2D.rotation += 30.0 * delta
	else:
		$Sprite2D.rotation = 0.0
		# Sombras
	shadow_timer += delta
	if shadow_timer >= shadow_interval:
		shadow_timer = 0.0
		spawn_shadow()


func spawn_shadow():
	var shadow = Sprite2D.new()
	shadow.texture = $Sprite2D.texture
	shadow.global_position = global_position
	shadow.rotation = $Sprite2D.global_rotation
	shadow.scale = $Sprite2D.scale
	
	var t = clamp(1.0 - (dim_timer / dim_duration), 0.1, 1.0)
	shadow.modulate = Color(t, t, t, 0.4)
	
	get_tree().get_root().get_node("Main").add_child(shadow)
	
	var tween = shadow.create_tween()
	tween.tween_property(shadow, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): shadow.queue_free())

func get_gravity_input() -> Vector2:
	if OS.has_feature("mobile"):
		var g = Input.get_accelerometer()
		if g == Vector3.ZERO:
			g = Input.get_gravity()
		return Vector2(g.x, -g.y)
	else:
		var dir = Vector2.ZERO
		if Input.is_key_pressed(KEY_LEFT):  dir.x -= 1
		if Input.is_key_pressed(KEY_RIGHT): dir.x += 1
		if Input.is_key_pressed(KEY_UP):    dir.y -= 1
		if Input.is_key_pressed(KEY_DOWN):  dir.y += 1
		return dir.normalized()

func update_brightness():
	var t = 1.0 - (dim_timer / dim_duration)
	modulate = Color(clamp(t, 0.1, 1.0), clamp(t, 0.1, 1.0), clamp(t, 0.1, 1.0), 1.0)
	light.energy = clamp(t * t, 0.0, 1.0) * max_light_energy
	if t <= 0.05:
		light.enabled = false
	else:
		light.enabled = true

func recharge():
	dim_timer = 0.0
	modulate = Color(1, 1, 1, 1)
	light.energy = max_light_energy
	light.enabled = true
	trigger_shockwave()

func lose_life():
	if is_dead:
		return
	is_dead = true
	get_tree().paused = false
	death_sequence()

func death_sequence():
	get_tree().paused = false
	set_process(true)
	set_physics_process(false)
	velocity = Vector2.ZERO  
	
	var tween = create_tween()
	
	# Parpadeo 6 veces siempre
	for i in range(6):
		tween.tween_callback(func(): modulate = Color(0, 0, 0, 1))
		tween.tween_callback(func(): light.energy = 0.0)
		tween.tween_interval(0.15)
		tween.tween_callback(func(): modulate = Color(1, 1, 1, 1))
		tween.tween_callback(func(): light.energy = max_light_energy)
		tween.tween_interval(0.15)
	tween.tween_callback(func():
		visible = false
		print("emitiendo died")
		emit_signal("died")
	)
func trigger_shockwave():
	var tween = create_tween()
	tween.tween_property(light, "energy", max_light_energy * 1, 0.2)
	tween.tween_property(light, "energy", max_light_energy, 0.2)

func take_damage():
	if damage_cooldown:
		return
	
	damage_cooldown = true
	dim_timer += dim_duration / 6.0

	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.add_score(-5)
	
	if dim_timer >= dim_duration:
		dim_timer = dim_duration
		lose_life()
		return
	
	# Parpadeo de daño
	var tween = create_tween()
	for i in range(2):
		tween.tween_callback(func():
			visible = false
			light.enabled = false
		)
		tween.tween_interval(0.1)
		tween.tween_callback(func():
			visible = true
			light.enabled = true
		)
		tween.tween_interval(0.1)
	
	# Cooldown antes de poder recibir daño de nuevo
	tween.tween_callback(func(): damage_cooldown = false)

func clamp_to_screen():
	var screen = get_viewport_rect().size
	var pos = global_position
	pos.x = clamp(pos.x, 20, screen.x - 20)
	pos.y = clamp(pos.y, 20, screen.y - 20)
	global_position = pos

func activate_powerup():
	if powerup_active:
		return
	powerup_active = true
	powerup_timer = 0.0
	powerup_indicator.visible = true
	trail_points.clear()  # limpia la estela
	trail.clear_points()
	$Sprite2D.texture = load("res://sprites/player_spiky.png")
	modulate = Color(1, 1, 1, 1) 
	light.enabled = false
	# Eliminamos todos los collectibles
	for c in get_tree().get_nodes_in_group("collectibles"):
		c.queue_free()
	
	get_tree().get_first_node_in_group("main").toggle_invert(true)
	await get_tree().create_timer(8.0).timeout
	deactivate_powerup()

func deactivate_powerup():
	powerup_active = false
	powerup_indicator.visible = false
	trail_points.clear()  
	trail.clear_points()
	$Sprite2D.texture = load("res://sprites/player.png")
	light.enabled = true
	light.energy = max_light_energy
	dim_timer = 0.0 
	get_tree().get_first_node_in_group("main").toggle_invert(false)

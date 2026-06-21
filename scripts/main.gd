extends Node2D

@export var collectible_scene: PackedScene
@export var enemy_scene: PackedScene
@export var chaser_scene: PackedScene
@onready var back_buffer = $BackBufferCopy
@onready var invert_rect = $CanvasLayer/InvertRect 
@onready var player = $Player
@export var powerup_scene: PackedScene
@onready var camera = $Camera2D
@onready var dark_overlay = $DarkOverlay
@onready var music = $Music
@onready var music_powerup = $MusicPowerup


var label_score_powerup: Label

var collectible_timer := 0.0
var collectible_interval := 2.5
var max_collectibles := 3
var enemy_timer := 0.0
var enemy_interval := 2.0
var score := 0
var score_timer := 0.0
var label_score_shadow: Label
var label_score: Label
var powerup_timer := -10.0
var powerup_interval := 30.0  # aparece cada 15 segundos
var waves := [
	[20, 0],
	[5, 0],    # oleada 0: tutorial
	[20, 60],
	[5, 0],   # oleada 1
	[20, 100],
	[5, 0],   # oleada 2
	[20, 140],
	[5, 0],   # oleada 3
	[20, 180],
	[10, 0],   # oleada 4
	[15, 220],
	[10, 0],   # oleada 5
	[15, 300], 
]
var enemy_types_pool := []
var current_wave := 0
var wave_timer := 0.0
var wave_enemies := []  
var next_enemy_spawn := 0.0
var enemy_spawn_interval := 0.0

func _ready():
	add_to_group("main")
	await get_tree().process_frame
	player.died.connect(_on_player_died)
	setup_score_label()
	# Inicializamos el pool de enemigos
	enemy_types_pool = [
		{"scene": enemy_scene, "cost": 10, "type": "small"},
		{"scene": enemy_scene, "cost": 5,  "type": "medium"},
		{"scene": enemy_scene, "cost": 10, "type": "large"},
		{"scene": chaser_scene, "cost": 10, "type": "chaser"},
	]
	start_wave(0)


func start_powerup_music():
	music.stream_paused = true
	music_powerup.play()

func stop_powerup_music():
	music_powerup.stop()
	music.stream_paused = false  # retoma donde quedó
func start_wave(wave_index: int):
	if wave_index >= waves.size():
		wave_index = waves.size() - 1
	
	current_wave = wave_index
	wave_timer = 0.0
	wave_enemies = []
	
	var points = waves[wave_index][1]
	var duration = waves[wave_index][0]
	
	# Generamos la lista de enemigos gastando los puntos
	generate_wave_enemies(points)
	
	# Distribuimos los spawns en el tiempo
	if wave_enemies.size() > 0:
		enemy_spawn_interval = duration / float(wave_enemies.size())
	next_enemy_spawn = 0.0 if wave_index > 0 else 9999.0

func setup_score_label():
	# Label negro que solo aparece con luz (encima)
	label_score = Label.new()
	add_child(label_score)
	label_score.z_index = 100
	var mat = CanvasItemMaterial.new()
	mat.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	label_score.material = mat
	var font = load("res://m12.TTF")
	label_score.add_theme_font_override("font", font)
	label_score.add_theme_font_size_override("font_size", 48)
	label_score.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label_score.position = Vector2(610, 5)
	label_score.text = "0000000"
	
	# Label blanco siempre visible (debajo)
	label_score_shadow = Label.new()
	add_child(label_score_shadow)
	label_score_shadow.z_index = 99
	var mat2 = CanvasItemMaterial.new()
	mat2.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	label_score_shadow.material = mat2
	var font2 = load("res://m12.TTF")
	label_score_shadow.add_theme_font_override("font", font2)
	label_score_shadow.add_theme_font_size_override("font_size", 48)
	label_score_shadow.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label_score_shadow.position = Vector2(610, 5)
	label_score_shadow.text = "0000000"

func add_score(amount: int):
	score += amount
	var text = "%07d" % score
	label_score.text = text
	label_score_shadow.text = text

func generate_wave_enemies(points: int):
	var remaining = points
	while remaining > 0:
		# Filtramos enemigos que podemos pagar
		var affordable = enemy_types_pool.filter(func(e): return e["cost"] <= remaining)
		if affordable.is_empty():
			break
		# Elegimos uno aleatorio
		var chosen = affordable[randi() % affordable.size()]
		wave_enemies.append(chosen)
		remaining -= chosen["cost"]
	# Mezclamos el orden
	wave_enemies.shuffle()
func get_score_interval() -> float:
	var reduction = (current_wave / 2) * 0.1
	return max(0.1, 0.8 - reduction)  # mínimo 0.1 para que no llegue a 0
func _process(delta):
	if not player.is_dead:
		score_timer += delta
		if score_timer >= get_score_interval():
			score_timer = 0.0
			add_score(1)

	var wave_duration = waves[current_wave][0] - 1.0
	var ratio = 1.0 - (wave_timer / wave_duration)

	collectible_timer += delta
	if collectible_timer >= collectible_interval:
		collectible_timer = 0.0
		spawn_collectible()

	powerup_timer += delta
	if powerup_timer >= powerup_interval:
		powerup_timer = 0.0
		spawn_powerup()

	var duration = waves[current_wave][0]
	wave_timer += delta

	# Spawneamos el siguiente enemigo de la lista
	if wave_enemies.size() > 0 and wave_timer >= next_enemy_spawn:
		var enemy_data = wave_enemies.pop_front()
		spawn_enemy_from_data(enemy_data)
		next_enemy_spawn += enemy_spawn_interval

	if wave_timer >= duration:
		start_wave(current_wave + 1)

func spawn_enemy_from_data(data: Dictionary):
	var pos = get_enemy_spawn_position()
	if pos == Vector2.ZERO:
		return
	var e = data["scene"].instantiate()
	add_child(e)
	if data["type"] == "chaser":
		e.setup(pos)
	else:
		e.setup(pos, data["type"])
func spawn_enemy():
	var pos = get_enemy_spawn_position()
	if pos == Vector2.ZERO:
		return  # no spawneó porque no encontró posición válida
	var e = enemy_scene.instantiate()
	add_child(e)
	e.setup(pos)

func spawn_chaser():
	var pos = get_enemy_spawn_position()
	if pos == Vector2.ZERO:
		return
	var c = chaser_scene.instantiate()
	add_child(c)
	c.setup(pos)

func get_enemy_spawn_position() -> Vector2:
	var screen = get_viewport_rect().size
	var player_pos = player.global_position
	var min_distance := 300.0
	
	for i in range(10):
		var side = randi() % 4
		var pos: Vector2
		match side:
			0: pos = Vector2(randf_range(0, screen.x), -50)
			1: pos = Vector2(randf_range(0, screen.x), screen.y + 50)
			2: pos = Vector2(-50, randf_range(0, screen.y))
			3: pos = Vector2(screen.x + 50, randf_range(0, screen.y))
		
		if pos.distance_to(player_pos) >= min_distance:
			return pos
	
	return Vector2.ZERO

func spawn_collectible():
	if player.powerup_active:
		return
	if get_tree().get_nodes_in_group("collectibles").size() >= max_collectibles:
		return
	var c = collectible_scene.instantiate()
	add_child(c)
	c.global_position = get_random_position()

func screen_shake(intensity: float, duration: float):
	var tween = create_tween()
	var original_pos = camera.offset
	var elapsed = 0.0
	var shake_duration = duration
	
	tween.tween_method(func(t: float):
		if t < shake_duration:
			camera.offset = Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			)
		else:
			camera.offset = Vector2.ZERO
	, 0.0, shake_duration + 0.1, shake_duration + 0.1)
func get_random_position() -> Vector2:
	var screen = get_viewport_rect().size
	return Vector2(
		randf_range(60, screen.x - 60),
		randf_range(120, screen.y - 60)
	)

func _on_player_died():
	print("player died - frenando musica")
	music.stop()
	print("music playing: ", music.playing)  # tiene que imprimir false
	save_highscore()
	await get_tree().create_timer(1.5).timeout
	$CanvasLayer.visible = false
	label_score.visible = false
	label_score_shadow.visible = false
	$Walls.visible = false
	dark_overlay.visible = false  # apagamos la oscuridad
	get_tree().paused = true
	var game_over = load("res://escenas/game_over.tscn").instantiate()
	get_tree().root.add_child(game_over)
	game_over.setup(score, load_highscore())


func spawn_powerup():
	if not powerup_scene:
		return
	# No spawnea si el jugador tiene el powerup activo
	if player.powerup_active:
		return
	# No spawnea si ya hay uno en pantalla
	if get_tree().get_nodes_in_group("powerups").size() > 0:
		return
	var p = powerup_scene.instantiate()
	add_child(p)
	p.global_position = get_random_position()

func save_highscore():
	var current_high = load_highscore()
	if score > current_high:
		var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
		file.store_32(score)
		file.close()

func load_highscore() -> int:
	if not FileAccess.file_exists("user://highscore.dat"):
		return 0
	var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
	var high = file.get_32()
	file.close()
	return high

func toggle_invert(enabled: bool):
	back_buffer.visible = enabled
	invert_rect.visible = enabled
	dark_overlay.visible = !enabled
	label_score.visible = !enabled  # ocultamos el negro con LIGHT_ONLY
	if enabled:
		# Durante powerup el blanco se pone negro
		label_score_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		expand_invert_wave()
	else:
		# Sin powerup vuelve a blanco
		label_score_shadow.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		dark_overlay.visible = true

func expand_invert_wave():
	var material = invert_rect.material
	var screen = get_viewport_rect().size
	# Centro del jugador en coordenadas UV (0 a 1)
	var player_uv = player.global_position / screen
	material.set_shader_parameter("center", player_uv)
	material.set_shader_parameter("radius", 0.0)
	
	var tween = create_tween()
	tween.tween_method(func(r: float):
		material.set_shader_parameter("radius", r)
	, 0.0, 3, 1.2)

extends Area2D

@onready var audio = $AudioStreamPlayer
@onready var music = $Music

func _ready():
	add_to_group("powerups")
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.activate_powerup()
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		audio.pitch_scale = randf_range(0.9, 1.1)
		audio.play()
		await audio.finished
		queue_free()

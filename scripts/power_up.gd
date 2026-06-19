extends Area2D

func _ready():
	add_to_group("powerups")
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("default")

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.activate_powerup()
		queue_free()

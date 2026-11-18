class_name Player
extends CharacterBody2D

@export var speed: float = 60.0
var can_move: bool = true
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		sprite.pause()
		return

	var dir := Input.get_vector("IZQUIERDA", "DERECHA", "ARRIBA", "ABAJO")
	velocity = dir * speed

	if dir == Vector2.ZERO:
		sprite.pause()
	elif abs(dir.x) > abs(dir.y):
		sprite.play("walk_side")
		sprite.flip_h = dir.x < 0
	elif dir.y > 0:
		sprite.play("walk_down")
	else:
		sprite.play("walk_up")

	move_and_slide()

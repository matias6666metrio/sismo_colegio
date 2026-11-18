class_name Companero
extends Node2D

@export var personaje: int = 3
@export var nombre: String = "Valentina"

const VEL := 66.0
const DIST := 18.0
const MARGEN := 4.0
const SEPARACION := 12.0

var sprite := AnimatedSprite2D.new()
var objetivo: Node2D = null
var moviendo := false

func _ready() -> void:
	add_to_group("companeros")
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	var tex: Texture2D = load("res://assets/personajes.png")
	var nombres := ["walk_down", "walk_up", "walk_side"]
	for a in 3:
		var n: String = nombres[a]
		sf.add_animation(n)
		sf.set_animation_speed(n, 8.0)
		sf.set_animation_loop(n, true)
		for f in 4:
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2((personaje * 3 + a) * 16, f * 24, 16, 24)
			sf.add_frame(n, at)
	sprite.sprite_frames = sf
	sprite.position = Vector2(0, -12)
	add_child(sprite)
	sprite.play("walk_down")
	sprite.pause()

func seguir(quien: Node2D) -> void:
	objetivo = quien

func _physics_process(delta: float) -> void:
	if objetivo == null:
		return
	var hacia := objetivo.global_position - global_position
	var dist := hacia.length()
	if dist > DIST + MARGEN:
		moviendo = true
	elif dist <= DIST:
		moviendo = false

	var paso := Vector2.ZERO
	if moviendo:
		paso = hacia.normalized() * VEL * delta

	for nodo in get_tree().get_nodes_in_group("companeros"):
		var otro := nodo as Companero
		if otro == null or otro == self or otro.objetivo == null:
			continue
		var v := global_position - otro.global_position
		if v.length() < SEPARACION:
			var dir := v.normalized() if v.length() > 0.1 else Vector2.DOWN
			paso += dir * 30.0 * delta

	global_position += paso

	if not moviendo:
		sprite.pause()
		return
	if abs(hacia.x) > abs(hacia.y):
		sprite.play("walk_side")
		sprite.flip_h = hacia.x < 0
	elif hacia.y > 0:
		sprite.play("walk_down")
	else:
		sprite.play("walk_up")

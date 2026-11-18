extends Area2D

const AVISO := 1.2
const VISIBLE_TRAS_IMPACTO := 0.6
var t := 0.0
var impacto := false

func _ready() -> void:
	monitoring = false
	z_index = 20

func _process(delta: float) -> void:
	t += delta
	if not impacto and t >= AVISO:
		_golpear()
	if impacto and t >= AVISO + VISIBLE_TRAS_IMPACTO:
		queue_free()
		return
	queue_redraw()

func _golpear() -> void:
	impacto = true
	monitoring = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	for b in get_overlapping_bodies():
		if b is Player and not Input.is_action_pressed("ACCION"):
			GameManager.perder_vida()
			break
	monitoring = false

func _draw() -> void:
	if not impacto:
		var k := t / AVISO
		draw_circle(Vector2.ZERO, lerpf(2.0, 7.0, k), Color(0, 0, 0, 0.35))
		var y := -lerpf(70.0, 0.0, k * k)
		draw_rect(Rect2(-4, y - 8, 8, 8), Color(0.55, 0.55, 0.55))
		draw_rect(Rect2(-4, y - 8, 8, 8), Color.BLACK, false, 1.0)
	else:
		draw_rect(Rect2(-6, -6, 12, 6), Color(0.55, 0.55, 0.55))
		draw_rect(Rect2(-6, -6, 12, 6), Color.BLACK, false, 1.0)
		draw_circle(Vector2(0, -2), 9.0, Color(1, 1, 1, 0.25))

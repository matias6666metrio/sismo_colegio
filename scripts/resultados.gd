extends Control

func _ready() -> void:
	var r: Dictionary = GameManager.resultado
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.09)
	bg.position = Vector2.ZERO
	bg.size = Vector2(256, 176)
	add_child(bg)

	var victoria: bool = r.get("victoria", false)
	var nota: String = r.get("nota", "Fallido")
	var n_est := 3 if nota == "Excelente" else (2 if nota == "Aceptable" else 0)

	_texto("¡TODOS A SALVO!" if victoria else "NO LOGRASTE EVACUAR", 8, 14,
		Color(1, 0.85, 0) if victoria else Color(1, 0.4, 0.3))
	for i in 3:
		add_child(_estrella(Vector2(108 + i * 20, 44), i < n_est))
	_texto("Final: " + nota.to_upper(), 58, 11, Color(0.5, 1, 0.5))

	var t: int = r.get("tiempo", 0)
	_texto("Vidas restantes: %d / 3" % r.get("vidas", 0), 78, 9, Color.WHITE)
	_texto("Compañeros rescatados: %d / 2" % r.get("rescatados", 0), 90, 9, Color.WHITE)
	_texto("Tiempo restante: %02d:%02d" % [floori(t / 60.0), t % 60], 102, 9, Color.WHITE)
	_texto("Decisiones: %d  |  Bonus: +%d" % [r.get("puntaje", 0),
		r.get("bonus_vidas", 0) + r.get("bonus_tiempo", 0)], 114, 9, Color.WHITE)
	_texto("TOTAL: %d puntos" % r.get("total", 0), 128, 11, Color(1, 0.85, 0))

	_texto("Recuerda: AGÁCHATE · CÚBRETE · SUJÉTATE", 146, 8, Color(0.5, 0.9, 1))
	_texto("Después: escaleras, nunca ascensor", 156, 7, Color(0.8, 0.8, 0.8))
	_texto("ESPACIO para jugar de nuevo", 166, 7, Color(1, 1, 1))

func _texto(t: String, y: float, tam: int, col: Color) -> void:
	var l := Label.new()
	l.text = t
	l.position = Vector2(0, y)
	l.size = Vector2(256, 14)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", col)
	add_child(l)

func _estrella(centro: Vector2, llena: bool) -> Polygon2D:
	var p := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 10:
		var rad := 10.0 if k % 2 == 0 else 4.0
		var a := -PI / 2.0 + k * PI / 5.0
		pts.append(Vector2(cos(a), sin(a)) * rad)
	p.polygon = pts
	p.position = centro
	p.color = Color(1, 0.85, 0) if llena else Color(0.3, 0.3, 0.3)
	return p

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ACCION"):
		GameManager.ir_a("res://escenas/nivel_1_aula.tscn")

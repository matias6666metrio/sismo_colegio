extends Node2D

const DURACION_SISMO := 15.0
const SEG_POR_DANO := 1.5
const ESCOMBRO := preload("res://escenas/escombro.tscn")
const CADA := 1.6
var t_escombro := 0.0

@onready var player: Player = $objetos/player
@onready var cam: Camera2D = $objetos/player/Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var valentina = $objetos/Valentina
@onready var salida: Area2D = $Salida

var puede_salir := false
var en_sismo := false
var t_sismo := 0.0
var t_dano := 0.0
var recibio_dano := false

func _ready() -> void:
	GameManager.juego_terminado.connect(_on_fin)
	hud.mostrar_aviso("10:15 a. m. - Clase de Matemáticas", 2.0)
	await get_tree().create_timer(2.5).timeout
	iniciar_sismo()
	salida.body_entered.connect(_on_salida)

func iniciar_sismo() -> void:
	GameManager.iniciar()
	en_sismo = true
	t_sismo = 0.0
	t_dano = 0.0
	recibio_dano = false
	player.can_move = false
	hud.mostrar_aviso("¡SISMO! Mantén ESPACIO para agacharte y cubrirte")

func _process(delta: float) -> void:
	if not en_sismo:
		return
	t_sismo += delta
	t_escombro += delta
	if t_escombro >= CADA:
		t_escombro = 0.0
		soltar_escombro()
	cam.offset = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	hud.set_progreso(t_sismo / DURACION_SISMO)

	if Input.is_action_pressed("ACCION"):
		t_dano = 0.0
	else:
		t_dano += delta
		if t_dano >= SEG_POR_DANO:
			t_dano = 0.0
			recibio_dano = true
			GameManager.perder_vida()

	if t_sismo >= DURACION_SISMO:
		terminar_sismo()

func terminar_sismo() -> void:
	en_sismo = false
	cam.offset = Vector2.ZERO
	hud.ocultar_progreso()
	player.can_move = true
	if recibio_dano:
		hud.mostrar_aviso("Terminó el sismo. Debiste mantener ESPACIO.", 3.0)
	else:
		GameManager.sumar_puntos(15)
		hud.mostrar_aviso("¡Bien! Te protegiste correctamente. +15", 3.0)
	decision_valentina()

func _on_fin(victoria: bool) -> void:
	en_sismo = false
	cam.offset = Vector2.ZERO
	player.can_move = false
	hud.mostrar_aviso("Fin del juego.")
	await get_tree().create_timer(2.0).timeout
	GameManager.mostrar_resultados(victoria)

func soltar_escombro() -> void:
	var e := ESCOMBRO.instantiate()
	var pos: Vector2
	if randf() < 0.5:
		pos = player.global_position + Vector2(randf_range(-24, 24), randf_range(-16, 16))
	else:
		pos = Vector2(randf_range(24, 232), randf_range(20, 160))
	add_child(e)
	e.global_position = pos

func decision_valentina() -> void:
	var d = $Dialogo
	player.can_move = false
	var op: int = await d.preguntar("Valentina", "No puedo moverme... ¡tengo mucho miedo!", [
		"Respira conmigo. Estoy contigo, vamos juntos.",
		"Quédate aquí, voy a buscar ayuda.",
		"¡Muévete ya!"])
	match op:
		0:
			valentina.seguir(player)
			GameManager.acompanantes["Valentina"] = 3
			GameManager.sumar_puntos(15)
			GameManager.rescatar()
			await d.decir("Aviso", "Hablar con calma ayuda a que otra persona reaccione y se mueva. +15")
		1:
			await d.decir("Aviso", "Nadie debe quedarse solo en una zona de riesgo. Acompaña y avisa.")
		2:
			valentina.seguir(player)
			GameManager.acompanantes["Valentina"] = 3
			GameManager.sumar_puntos(5)
			GameManager.rescatar()
			GameManager.restar_tiempo(10)
			await d.decir("Aviso", "Presionar o jalar a alguien en pánico puede empeorar todo. -10 s")
	player.can_move = true
	puede_salir = true
	hud.mostrar_aviso("Sal por la puerta del salón.", 3.0)

func _on_salida(b: Node2D) -> void:
	if b is Player and puede_salir:
		puede_salir = false
		GameManager.ir_a("res://escenas/nivel_2_pasillo.tscn")

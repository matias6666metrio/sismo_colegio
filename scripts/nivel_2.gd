extends Node2D

const COMPANERO := preload("res://escenas/companero.tscn")

@onready var player: Player = $objetos/player
@onready var hud = $HUD
@onready var dialogo = $Dialogo
@onready var daniel = $objetos/Daniel
@onready var zona_daniel: Area2D = $ZonaDaniel
@onready var zona_escaleras: Area2D = $ZonaEscaleras
var salio := false
var decidido_daniel := false

func _ready() -> void:
	if not GameManager.activo:
		GameManager.iniciar()
	GameManager.juego_terminado.connect(_on_fin)
	var i := 0
	for nombre in GameManager.acompanantes:
		var c = COMPANERO.instantiate()
		c.personaje = GameManager.acompanantes[nombre]
		c.nombre = nombre
		$objetos.add_child(c)
		c.global_position = player.global_position + Vector2(-12 - 10 * i, 0)
		c.seguir(player)
		i += 1
	zona_daniel.body_entered.connect(_on_zona_daniel)
	zona_escaleras.body_entered.connect(_on_escaleras)
	hud.mostrar_aviso("Pasillo del 3.er piso. Sigue las señales de salida.", 3.0)

func _on_zona_daniel(b: Node2D) -> void:
	if not (b is Player) or decidido_daniel:
		return
	decidido_daniel = true
	player.can_move = false
	var op: int = await dialogo.preguntar("Daniel", "¡Tomemos el ascensor, es más rápido!", [
		"No. Vamos por las escaleras: el ascensor puede quedarse atrapado.",
		"Sí, entremos al ascensor.",
		"Haz lo que quieras. Yo sigo solo."])
	match op:
		0:
			daniel.seguir(player)
			GameManager.acompanantes["Daniel"] = 2
			GameManager.sumar_puntos(15)
			GameManager.rescatar()
			await dialogo.decir("Aviso", "En un sismo nunca se usa el ascensor: puede detenerse o quedar sin energía. +15")
		1:
			GameManager.perder_vida()
			GameManager.restar_tiempo(30)
			await dialogo.decir("Aviso", "El ascensor se detuvo entre pisos: -1 vida y -30 s. Usa siempre las escaleras.")
		2:
			await dialogo.decir("Aviso", "En una emergencia, el trabajo en equipo aumenta las posibilidades de todos.")
	player.can_move = true

func _on_escaleras(b: Node2D) -> void:
	if b is Player and decidido_daniel and not salio:
		salio = true
		player.can_move = false
		hud.mostrar_aviso("Bajas por las escaleras sin correr ni empujar.", 2.0)
		await get_tree().create_timer(1.5).timeout
		GameManager.ir_a("res://escenas/nivel_3_patio.tscn")

func _on_fin(victoria: bool) -> void:
	player.can_move = false
	hud.mostrar_aviso("Fin del juego.")
	await get_tree().create_timer(2.0).timeout
	GameManager.mostrar_resultados(victoria)

extends Node2D

const COMPANERO := preload("res://escenas/companero.tscn")

@onready var player: Player = $objetos/player
@onready var hud = $HUD
@onready var dialogo = $Dialogo
@onready var zona: Area2D = $ZonaPunto

var hecho := false

func _ready() -> void:
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
	zona.body_entered.connect(_on_zona)
	hud.mostrar_aviso("Patio del colegio. Ve al punto de encuentro.", 3.0)

func _on_zona(b: Node2D) -> void:
	if not (b is Player) or hecho:
		return
	hecho = true
	player.can_move = false
	var correcto := false
	while not correcto and GameManager.activo:
		var op: int = await dialogo.preguntar("Profesora Marta", "¿Falta alguien de nuestro curso?", [
			"Estamos todos. No regresaremos al edificio.",
			"Voy rápido por mi mochila y mi celular."])
		if op == 0:
			correcto = true
			GameManager.sumar_puntos(10)
			await dialogo.decir("Aviso", "Después de un sismo no se reingresa al edificio hasta que lo autorice personal calificado. +10")
		else:
			GameManager.perder_vida()
			if GameManager.activo:
				await dialogo.decir("Aviso", "Una réplica sacudió el edificio. Las pertenencias se reemplazan, tu vida no. -1 vida")
	if GameManager.activo:
		GameManager.mostrar_resultados(true)

func _on_fin(victoria: bool) -> void:
	player.can_move = false
	hud.mostrar_aviso("Fin del juego.")
	await get_tree().create_timer(2.0).timeout
	GameManager.mostrar_resultados(victoria)

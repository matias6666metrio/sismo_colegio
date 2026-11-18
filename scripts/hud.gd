extends CanvasLayer

@onready var l_vidas: Label = $Barra/Vidas
@onready var l_tiempo: Label = $Barra/Tiempo
@onready var l_puntos: Label = $Barra/Puntos
@onready var l_resc: Label = $Barra/Rescatados

func _ready() -> void:
	_ready_extra()
	GameManager.vidas_cambiadas.connect(_on_vidas)
	GameManager.tiempo_cambiado.connect(_on_tiempo)
	GameManager.puntaje_cambiado.connect(_on_puntos)
	GameManager.rescatados_cambiados.connect(_on_resc)
	_on_vidas(GameManager.vidas)
	_on_tiempo(GameManager.tiempo)
	_on_puntos(GameManager.puntaje)
	_on_resc(GameManager.rescatados)

func _on_vidas(v: int) -> void:
	l_vidas.text = "Vidas: %d" % v

func _on_tiempo(s: int) -> void:
	l_tiempo.text = "%02d:%02d" % [floori(s / 60.0), s % 60]

func _on_puntos(p: int) -> void:
	l_puntos.text = "Pts: %d" % p

func _on_resc(r: int) -> void:
	l_resc.text = "Resc: %d/2" % r

@onready var aviso: Label = $Aviso
@onready var progreso: ProgressBar = $Progreso

func _ready_extra() -> void:
	aviso.hide()
	progreso.hide()
	progreso.max_value = 1.0

func mostrar_aviso(texto: String, seg: float = 0.0) -> void:
	aviso.text = texto
	aviso.show()
	if seg > 0.0:
		await get_tree().create_timer(seg).timeout
		aviso.hide()

func set_progreso(v: float) -> void:
	progreso.show()
	progreso.value = v

func ocultar_progreso() -> void:
	progreso.hide()

extends Node

signal vidas_cambiadas(vidas: int)
signal tiempo_cambiado(segundos: int)
signal puntaje_cambiado(puntos: int)
signal rescatados_cambiados(n: int)
signal juego_terminado(victoria: bool)

const VIDAS_MAX := 3
const TIEMPO_INICIAL := 300

var resultado: Dictionary = {}
var vidas := VIDAS_MAX
var tiempo := TIEMPO_INICIAL
var puntaje := 0
var rescatados := 0
var activo := false
var _acum := 0.0
var acompanantes: Dictionary = {}

func iniciar() -> void:
	vidas = VIDAS_MAX
	tiempo = TIEMPO_INICIAL
	puntaje = 0
	rescatados = 0
	_acum = 0.0
	activo = true
	vidas_cambiadas.emit(vidas)
	tiempo_cambiado.emit(tiempo)
	puntaje_cambiado.emit(puntaje)
	rescatados_cambiados.emit(rescatados)
	acompanantes.clear()

func _process(delta: float) -> void:
	if not activo:
		return
	_acum += delta
	if _acum >= 1.0:
		_acum -= 1.0
		restar_tiempo(1)

func restar_tiempo(seg: int) -> void:
	tiempo = max(tiempo - seg, 0)
	tiempo_cambiado.emit(tiempo)
	if tiempo == 0:
		terminar(false)

func perder_vida(n: int = 1) -> void:
	if not activo:
		return
	vidas = max(vidas - n, 0)
	vidas_cambiadas.emit(vidas)
	if vidas == 0:
		terminar(false)

func ganar_vida(n: int = 1) -> void:
	vidas = min(vidas + n, VIDAS_MAX)
	vidas_cambiadas.emit(vidas)

func sumar_puntos(p: int) -> void:
	puntaje += p
	puntaje_cambiado.emit(puntaje)

func rescatar() -> void:
	rescatados += 1
	rescatados_cambiados.emit(rescatados)

func terminar(victoria: bool) -> void:
	if not activo:
		return
	activo = false
	juego_terminado.emit(victoria)

func ir_a(ruta: String) -> void:
	var cl := CanvasLayer.new()
	cl.layer = 100
	var r := ColorRect.new()
	r.color = Color(0, 0, 0, 0)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(r)
	get_tree().root.add_child(cl)
	var t := create_tween()
	t.tween_property(r, "color:a", 1.0, 0.4)
	await t.finished
	get_tree().change_scene_to_file(ruta)
	await get_tree().process_frame
	await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(r, "color:a", 0.0, 0.4)
	await t2.finished
	cl.queue_free()

func mostrar_resultados(victoria: bool) -> void:
	activo = false
	var bonus_vidas := vidas * 5
	var bonus_tiempo := mini(floori(tiempo / 30.0), 10)
	var total := puntaje
	if victoria:
		total += bonus_vidas + bonus_tiempo
	var nota := "Fallido"
	if victoria:
		nota = "Excelente" if (total >= 65 and vidas >= 2) else "Aceptable"
	resultado = {
		"victoria": victoria, "vidas": vidas, "rescatados": rescatados,
		"tiempo": tiempo, "puntaje": puntaje,
		"bonus_vidas": bonus_vidas if victoria else 0,
		"bonus_tiempo": bonus_tiempo if victoria else 0,
		"total": total, "nota": nota
	}
	ir_a("res://escenas/resultados.tscn")

extends CanvasLayer

signal elegida(indice: int)

@onready var panel: PanelContainer = $Panel
@onready var texto: Label = $Panel/Caja/Texto
@onready var cont: VBoxContainer = $Panel/Caja/Opciones

var _labels: Array[Label] = []
var _textos: Array = []
var _sel := 0
var _esperando := false
var _con_opciones := false

func _ready() -> void:
	panel.hide()

func preguntar(quien: String, mensaje: String, opciones: Array) -> int:
	_limpiar()
	texto.text = "%s: %s" % [quien, mensaje]
	_textos = opciones
	for o in opciones:
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 8)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cont.add_child(l)
		_labels.append(l)
	_sel = 0
	_refrescar()
	_con_opciones = true
	_esperando = true
	panel.show()
	var i: int = await elegida
	panel.hide()
	return i

func decir(quien: String, mensaje: String) -> void:
	_limpiar()
	texto.text = "%s: %s\n(ESPACIO para continuar)" % [quien, mensaje]
	_con_opciones = false
	_esperando = true
	panel.show()
	await elegida
	panel.hide()

func _limpiar() -> void:
	for l in _labels:
		l.queue_free()
	_labels.clear()

func _refrescar() -> void:
	for i in _labels.size():
		var marca := "> " if i == _sel else "   "
		_labels[i].text = marca + String(_textos[i])

func _unhandled_input(event: InputEvent) -> void:
	if not _esperando:
		return
	if _con_opciones:
		if event.is_action_pressed("ARRIBA"):
			_sel = wrapi(_sel - 1, 0, _labels.size())
			_refrescar()
		elif event.is_action_pressed("ABAJO"):
			_sel = wrapi(_sel + 1, 0, _labels.size())
			_refrescar()
	if event.is_action_pressed("ACCION"):
		_esperando = false
		get_viewport().set_input_as_handled()
		elegida.emit(_sel)

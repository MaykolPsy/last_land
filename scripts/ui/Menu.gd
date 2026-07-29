extends Control

const GAME_SCENE := "res://scenes/Gameplay.tscn"

@onready var panel: Control = $TextureRect
@onready var btn_play: Button = %PlayButton
@onready var btn_exit: Button = %ExitButton
@onready var btn_options: Button = %OptionsButton

# Nodo 3D que rota al barco (ajusta ruta según tu escena)
@onready var boat_pivot: Node3D = $"../BoatPivot"

var play_started: bool = false

func _ready() -> void:
	_style_button_line_hover(btn_play)
	_style_button_line_hover(btn_exit)
	_style_button_line_hover(btn_options)

	get_tree().paused = false
	_setup_initial_state()
	_play_intro_animation()

	btn_play.pressed.connect(_on_play_pressed)
	btn_exit.pressed.connect(_on_quit_pressed)

func _process(delta: float) -> void:
	# movimiento suave del barco en el menú
	if not play_started and boat_pivot:
		boat_pivot.rotation.y += 0.15 * delta

func _setup_initial_state() -> void:
	panel.modulate.a = 0.0
	panel.position.y += 40.0
	btn_play.disabled = true
	btn_exit.disabled = true
	btn_options.disabled = true

func _play_intro_animation() -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tw.tween_property(panel, "modulate:a", 1.0, 0.35)
	tw.parallel().tween_property(panel, "position:y", panel.position.y - 40.0, 0.45)

	await tw.finished
	btn_play.disabled = false
	btn_exit.disabled = false
	btn_options.disabled = false

func _on_play_pressed() -> void:
	play_started = true
	_disable_buttons()

	# giro del barco al presionar iniciar
	if boat_pivot:
		var boat_tw := create_tween()
		boat_tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		boat_tw.tween_property(boat_pivot, "rotation:y", boat_pivot.rotation.y + PI, 0.9)

	await _play_out_animation()
	_goto_scene(GAME_SCENE)

func _on_quit_pressed() -> void:
	_disable_buttons()
	await _play_out_animation()
	get_tree().quit()

func _disable_buttons() -> void:
	btn_play.disabled = true
	btn_exit.disabled = true
	btn_options.disabled = true

func _play_out_animation() -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(panel, "modulate:a", 0.0, 0.25)
	tw.parallel().tween_property(panel, "position:y", panel.position.y + 25.0, 0.25)
	await tw.finished

func _goto_scene(path: String) -> void:
	var sm = get_node_or_null("/root/SceneManager")
	if sm and sm.has_method("change_scene"):
		sm.change_scene(path)
	else:
		get_tree().change_scene_to_file(path)

func _style_button_line_hover(btn: Button) -> void:
	if btn == null:
		return

	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 3
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)

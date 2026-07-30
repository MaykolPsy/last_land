extends Control

@onready var panel: Control = $TextureRect
@onready var btn_play: Button = %PlayButton
@onready var btn_exit: Button = %ExitButton
@onready var btn_options: Button = %OptionsButton
@onready var boat_pivot: Node3D = get_tree().current_scene.find_child("BoatPivot", true, false) as Node3D

var play_started: bool = false

func _print_tree(node: Node, depth: int = 0) -> void:
	print("  ".repeat(depth), node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		_print_tree(child, depth + 1)
		
func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	play_started = false

	_style_button_line_hover(btn_play)
	_style_button_line_hover(btn_exit)
	_style_button_line_hover(btn_options)

	get_tree().paused = false
	_setup_initial_state()
	_play_intro_animation()

	if not btn_play.pressed.is_connected(_on_play_pressed):
		btn_play.pressed.connect(_on_play_pressed)
	if not btn_exit.pressed.is_connected(_on_quit_pressed):
		btn_exit.pressed.connect(_on_quit_pressed)

func _process(delta: float) -> void:
	if not visible or play_started:
		return
	if boat_pivot:
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
	if play_started:
		return
	play_started = true
	_disable_buttons()
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.STORY)
	SceneManager.change_scene("res://scenes/levels/Level_01_Water.tscn")
	EventBus.game_started.emit()	
		
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

func _style_button_line_hover(btn: Button) -> void:
	if btn == null:
		return
	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 3
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)

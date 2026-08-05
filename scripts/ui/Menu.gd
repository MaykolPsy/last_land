extends Control

@onready var btn_play: Button = %PlayButton
@onready var btn_exit: Button = %ExitButton
@onready var btn_options: Button = %OptionsButton

var play_started := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	modulate.a = 1.0
	play_started = false

	_style_button_line_hover(btn_play)
	_style_button_line_hover(btn_exit)
	_style_button_line_hover(btn_options)

	if btn_play and not btn_play.pressed.is_connected(_on_play_pressed):
		btn_play.pressed.connect(_on_play_pressed)
	if btn_exit and not btn_exit.pressed.is_connected(_on_quit_pressed):
		btn_exit.pressed.connect(_on_quit_pressed)

func _process(_delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	if play_started:
		return
	play_started = true
	_disable_buttons()
	visible = false
	get_tree().paused = false
	GameStateManager.change_state(GameStateManager.GameState.STORY)
	get_tree().change_scene_to_file("res://scenes/levels/Level_02_Islands.tscn")
func _on_quit_pressed() -> void:
	_disable_buttons()
	get_tree().quit()

func _disable_buttons() -> void:
	if btn_play: btn_play.disabled = true
	if btn_exit: btn_exit.disabled = true
	if btn_options: btn_options.disabled = true

func _style_button_line_hover(btn: Button) -> void:
	if btn == null:
		return
	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 3
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)

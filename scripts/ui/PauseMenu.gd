extends Control

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

@onready var play_button: Button = %PlayButton
@onready var menu_button: Button = %MenuButton
@onready var retry_button: Button = %RetryButton

var _resume_state: int = GameStateManager.GameState.STORY

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	_connect_signals()

func _connect_signals() -> void:
	if play_button and not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)
	if menu_button and not menu_button.pressed.is_connected(_on_menu_button_pressed):
		menu_button.pressed.connect(_on_menu_button_pressed)
	if retry_button and not retry_button.pressed.is_connected(_on_retry_button_pressed):
		retry_button.pressed.connect(_on_retry_button_pressed)

func show_pause() -> void:
	if visible:
		return

	var st := GameStateManager.current_state
	if st != GameStateManager.GameState.STORY and st != GameStateManager.GameState.INFINITE:
		return

	_resume_state = st
	visible = true
	GameStateManager.change_state(GameStateManager.GameState.PAUSED)
	play_button.grab_focus()

func hide_pause() -> void:
	if not visible:
		return

	visible = false
	GameStateManager.change_state(_resume_state)

func _on_play_button_pressed() -> void:
	hide_pause()

func _on_menu_button_pressed() -> void:
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.MENU)

	var sm := get_node_or_null("/root/SceneManager")
	if sm and sm.has_method("change_scene"):
		sm.change_scene(MAIN_MENU_SCENE)
	else:
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_retry_button_pressed() -> void:
	visible = false

	# Importante: no pasar por STORY aquí si vas a recargar escena
	get_tree().paused = false

	var lf := get_node_or_null("/root/LevelFlowManager")
	if lf == null:
		lf = get_node_or_null("/root/LevelFlow")
	if lf and lf.has_method("restart_level"):
		lf.call("restart_level")

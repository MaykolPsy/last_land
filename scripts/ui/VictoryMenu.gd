extends Control

@onready var next_btn: Button = %NextButton
@onready var retry_btn: Button = %RetryButton
@onready var menu_btn: Button = %MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	if not next_btn.pressed.is_connected(_on_next_pressed):
		next_btn.pressed.connect(_on_next_pressed)
	if not retry_btn.pressed.is_connected(_on_retry_pressed):
		retry_btn.pressed.connect(_on_retry_pressed)
	if not menu_btn.pressed.is_connected(_on_menu_pressed):
		menu_btn.pressed.connect(_on_menu_pressed)

func show_victory() -> void:
	visible = true
	z_index = 999
	GameStateManager.change_state(GameStateManager.GameState.VICTORY)

func _get_level_flow() -> Node:
	var lf := get_node_or_null("/root/LevelFlowManager")
	if lf == null:
		lf = get_node_or_null("/root/LevelFlow")
	return lf

func _on_next_pressed() -> void:
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.STORY)

	var lf := _get_level_flow()
	if lf and lf.has_method("next_level"):
		var has_next: bool = lf.call("next_level")
		if not has_next:
			SceneManager.change_scene("res://scenes/menus/MainMenu.tscn")
	else:
		push_error("[VictoryMenu] No existe LevelFlow autoload")

func _on_retry_pressed() -> void:
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.STORY)

	var lf := _get_level_flow()
	if lf and lf.has_method("restart_level"):
		lf.call("restart_level")
	else:
		push_error("[VictoryMenu] LevelFlow no tiene restart_level()")

func _on_menu_pressed() -> void:
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.MENU)

	var lf := _get_level_flow()
	if lf and lf.has_method("reset_run"):
		lf.call("reset_run")

	SceneManager.change_scene("res://scenes/menus/MainMenu.tscn")

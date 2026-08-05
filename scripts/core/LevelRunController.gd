extends Node
class_name LevelRunController

var finished: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Arranque limpio SIEMPRE (importante al correr escena suelta/restart)
	get_tree().paused = false
	finished = false

	if ScoreManager and ScoreManager.has_method("reset_run"):
		ScoreManager.reset_run()
	elif ScoreManager and ScoreManager.has_method("reset"):
		ScoreManager.reset()

	# fuerza gameplay
	if GameStateManager.current_state != GameStateManager.GameState.STORY:
		GameStateManager.change_state(GameStateManager.GameState.STORY)

	if EventBus and EventBus.has_signal("game_started"):
		if not EventBus.game_started.is_connected(_on_game_started):
			EventBus.game_started.connect(_on_game_started)
		EventBus.game_started.emit()

func _exit_tree() -> void:
	if EventBus and EventBus.has_signal("game_started"):
		if EventBus.game_started.is_connected(_on_game_started):
			EventBus.game_started.disconnect(_on_game_started)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_with_menu()
		get_viewport().set_input_as_handled()

func _toggle_pause_with_menu() -> void:
	var st := GameStateManager.current_state

	if st == GameStateManager.GameState.MENU \
	or st == GameStateManager.GameState.GAME_OVER \
	or st == GameStateManager.GameState.VICTORY:
		return

	var scene := get_tree().current_scene
	if scene == null:
		return

	var pause_menu := scene.find_child("PauseMenu", true, false)
	if pause_menu == null:
		push_error("No se encontró PauseMenu")
		return

	if st == GameStateManager.GameState.PAUSED:
		if pause_menu.has_method("hide_pause"):
			pause_menu.call("hide_pause")
	else:
		if pause_menu.has_method("show_pause"):
			pause_menu.call("show_pause")

func _on_game_started() -> void:
	if not is_inside_tree():
		return

	finished = false
	get_tree().paused = false

	var st := GameStateManager.current_state
	if st != GameStateManager.GameState.STORY and st != GameStateManager.GameState.INFINITE:
		GameStateManager.change_state(GameStateManager.GameState.STORY)

func _process(_delta: float) -> void:
	if finished or not is_inside_tree():
		return

	if GameStateManager.current_state != GameStateManager.GameState.STORY:
		return

	if ScoreManager.get_distance() >= LevelFlowManager.get_current_goal():
		finished = true
		GameStateManager.change_state(GameStateManager.GameState.VICTORY)

		var scene := get_tree().current_scene
		if scene == null:
			return

		var victory_menu := scene.find_child("VictoryMenu", true, false)
		if victory_menu and victory_menu.has_method("show_victory"):
			victory_menu.show_victory()
		else:
			push_error("No se encontró VictoryMenu o no tiene show_victory()")

extends Node3D

var pause_menu: Node = null
var menu: CanvasItem = null
var victory: CanvasItem = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_menu = find_child("PauseMenu", true, false)
	menu = find_child("Menu", true, false) as CanvasItem
	victory = find_child("VictoryMenu", true, false) as CanvasItem

	if menu: menu.visible = true
	if pause_menu and pause_menu.has_method("hide_pause"): pause_menu.call("hide_pause")
	if victory: victory.visible = false

	GameStateManager.change_state(GameStateManager.GameState.MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if pause_menu == null:
		push_error("No se encontró PauseMenu")
		return

	if GameStateManager.current_state == GameStateManager.GameState.MENU:
		return
	if GameStateManager.current_state == GameStateManager.GameState.GAME_OVER:
		return

	if GameStateManager.current_state == GameStateManager.GameState.PAUSED:
		pause_menu.call("hide_pause")
		GameStateManager.change_state(GameStateManager.GameState.STORY)
	else:
		pause_menu.call("show_pause")
		GameStateManager.change_state(GameStateManager.GameState.PAUSED)

func start_run() -> void:
	if menu: menu.visible = false
	if victory: victory.visible = false
	if pause_menu and pause_menu.has_method("hide_pause"): pause_menu.call("hide_pause")
	GameStateManager.change_state(GameStateManager.GameState.STORY)

func show_victory() -> void:
	# si no tienes estado VICTORY, solo muestra panel y pausa con PAUSED
	if victory: victory.visible = true
	GameStateManager.change_state(GameStateManager.GameState.PAUSED)

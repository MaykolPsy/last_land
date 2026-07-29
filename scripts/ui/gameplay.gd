extends Node3D

var pause_menu: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu = find_child("PauseMenu", true, false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if pause_menu == null:
		push_error("No se encontró PauseMenu")
		return

	if GameStateManager.current_state == GameStateManager.GameState.PAUSED:
		pause_menu.call("hide_pause")
	else:
		pause_menu.call("show_pause")
